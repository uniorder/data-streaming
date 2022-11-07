package com.esteel.streaming.rabbitmq.e1;

import com.esteel.streaming.rabbitmq.SensorAvgResult;
import com.esteel.streaming.rabbitmq.SensorDeserializationSchema;
import com.esteel.streaming.rabbitmq.SensorReading;
import com.esteel.streaming.rabbitmq.SensorTimeAssigner;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.windowing.WindowFunction;
import org.apache.flink.streaming.api.windowing.assigners.TumblingEventTimeWindows;
import org.apache.flink.streaming.api.windowing.time.Time;
import org.apache.flink.streaming.api.windowing.windows.TimeWindow;
import org.apache.flink.streaming.connectors.rabbitmq.RMQSource;
import org.apache.flink.streaming.connectors.rabbitmq.common.RMQConnectionConfig;
import org.apache.flink.util.Collector;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.Duration;
import java.util.concurrent.TimeUnit;

/**
 * @author Kehaw
 * @since JDK 11
 */
public class RabbitStreamingJob {

    public static void main(String[] args) throws Exception {
        // 创建 Flink 执行环境
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 配置失败重启策略
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
                Integer.MAX_VALUE, // 尝试重启的次数
                org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS) // 间隔
        ));

        RMQSource<SensorReading> source = buildSource();

        // 设置时间戳和水位线
        WatermarkStrategy<SensorReading> watermarkStrategy = WatermarkStrategy
                .<SensorReading>forBoundedOutOfOrderness(Duration.ofSeconds(5))
                .withTimestampAssigner(new SensorTimeAssigner());

        // 将数据源添加到环境中
        DataStream<SensorReading> sensorData = env.addSource(source)
                .assignTimestampsAndWatermarks(watermarkStrategy)
                .setParallelism(2);

        DataStream<SensorAvgResult> avgTemp = sensorData
                // 根据指标ID对数据进行分组
                .keyBy(SensorReading::getMetricId)
                // 再将数据按5秒的滚动窗口进行拆分
                .window(TumblingEventTimeWindows.of(Time.seconds(5)))
                // 使用用户自定义的函数进行计算，例如此处是计算5秒内的平均值
                .apply(new TemperatureAverager());

        // 将结果打印（这里是调用toString方法）
        // 如果需要进行下一步写入，需要在这里进行定义并写入数据汇
        avgTemp.print();
        // 提交执行
        env.execute("Compute average sensor temperature");

    }

    private static RMQSource<SensorReading> buildSource() {
        // 初始化 Rabbit MQ 链接配置
        final RMQConnectionConfig connectionConfig = new RMQConnectionConfig
                .Builder()
                .setHost("mss-mq.dev.mysteelsoft.tech")
                .setPort(5672)
                .setVirtualHost("iothub")
                .setUserName("iothub")
                .setPassword("b1D3+x^X2cs")
                .build();

        // 定义数据源
        return new RMQSource<>(
                connectionConfig,
                "iothub-flink-receive-q",
                true,
                new SensorDeserializationSchema());
    }

    public static class TemperatureAverager implements WindowFunction<SensorReading, SensorAvgResult, Long, TimeWindow> {

        /**
         * @param sensorId 分组ID，这里是指标ID
         * @param window   窗口对象
         * @param input    输入的数据
         * @param out      输出的数据
         */
        @Override
        public void apply(Long sensorId, TimeWindow window, Iterable<SensorReading> input, Collector<SensorAvgResult> out) {
            int count = 0;
            BigDecimal sum = new BigDecimal("0");
            for (SensorReading sensorReading : input) {
                count++;
                sum = sum.add(sensorReading.getMetricValue());
            }
            if (count == 0) {
                return;
            }
            BigDecimal result = sum.divide(BigDecimal.valueOf(count), 4, RoundingMode.HALF_UP);
            SensorAvgResult avg = new SensorAvgResult();
            avg.setMid(sensorId);
            avg.setAvgValue(result);
            out.collect(avg);
        }
    }
}
