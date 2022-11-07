package com.esteel.streaming.rabbitmq.e2;

import com.esteel.streaming.rabbitmq.SensorDeserializationSchema;
import com.esteel.streaming.rabbitmq.SensorReading;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.connector.jdbc.JdbcConnectionOptions;
import org.apache.flink.connector.jdbc.JdbcExecutionOptions;
import org.apache.flink.connector.jdbc.JdbcSink;
import org.apache.flink.connector.jdbc.JdbcStatementBuilder;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;
import org.apache.flink.streaming.api.functions.sink.SinkFunction;
import org.apache.flink.streaming.connectors.rabbitmq.RMQSource;
import org.apache.flink.streaming.connectors.rabbitmq.common.RMQConnectionConfig;
import org.apache.flink.table.api.DataTypes;
import org.apache.flink.table.api.Schema;
import org.apache.flink.table.api.Table;
import org.apache.flink.table.api.bridge.java.StreamTableEnvironment;
import org.apache.flink.types.Row;

import java.math.BigDecimal;
import java.util.Objects;

import static org.apache.flink.table.api.Expressions.$;

/**
 * @author Kehaw
 * @since 2022/11/1
 */
public class RabbitStreamingTableJob {

    private static final String TABLE_COL_MID = "mid";
    private static final String TABLE_COL_AVG_VAL = "avgValue";

    private static final String TABLE_COL_TIME = "createTime";

    public static void main(String[] args) throws Exception {
        // 环境
        final StreamExecutionEnvironment streamEnv = StreamExecutionEnvironment.getExecutionEnvironment();
        // Stream Table，基于流的 Table 环境
        StreamTableEnvironment tableEnv = StreamTableEnvironment.create(streamEnv);

        DataStream<SensorReading> sensorData = streamEnv.addSource(buildSource())
                .assignTimestampsAndWatermarks(WatermarkStrategy.noWatermarks())
                .setParallelism(1);

        // 建表
        Table inputTable = tableEnv.fromDataStream(sensorData);
        Table resultTable = inputTable.groupBy($("metricId"), $("metricTime"))
                .select($("metricId").as(TABLE_COL_MID),
                        $("metricValue").avg().as(TABLE_COL_AVG_VAL),
                        $("metricTime").as(TABLE_COL_TIME));

        Schema schema = Schema.newBuilder()
                .column(TABLE_COL_MID, DataTypes.BIGINT())
                .column(TABLE_COL_AVG_VAL, DataTypes.DECIMAL(10, 2))
                .column(TABLE_COL_TIME, DataTypes.BIGINT())
                .build();
        DataStream<Row> resultStream = tableEnv.toChangelogStream(resultTable, schema);

        resultStream.print();

        // 注意！！此处仅作为 Sink 示例，实际上处理数据的逻辑要更复杂，例如判断数据如果已经存在就更新而不是添加！！！
        resultStream.addSink(buildSink()).name("Sink data result to MySQL").setParallelism(1);
        // 执行代码
        streamEnv.execute();
    }

    /**
     * 构建 Sink
     * @return Sink
     */
    private static SinkFunction<Row> buildSink() {
        JdbcStatementBuilder<Row> jdbcStatementBuilder = (preparedStatement, row) -> {
            Object o1 = row.getField(TABLE_COL_MID);
            long mid = 0L;
            if (Objects.nonNull(o1)) {
                mid = Long.parseLong(o1.toString());
            }

            Object o2 = row.getField(TABLE_COL_AVG_VAL);
            BigDecimal value = new BigDecimal(0);
            if (Objects.nonNull(o2)) {
                value = new BigDecimal(o2.toString());
            }

            Object o3 = row.getField(TABLE_COL_TIME);
            long ts = 0L;
            if (Objects.nonNull(o3)) {
                ts = Long.parseLong(o3.toString());
            }
            preparedStatement.setLong(1, mid);
            preparedStatement.setBigDecimal(2, value);
            preparedStatement.setLong(3, ts);
        };

        JdbcConnectionOptions connectionOptions = new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withDriverName("com.mysql.cj.jdbc.Driver")
                .withUrl("jdbc:mysql://10.0.170.23:3306/esteel_test?autoReconnect=true&serverTimezone=GMT%2B8")
                .withUsername("gehao")
                .withPassword("HiKLlsAu8#^u")
                .build();

        JdbcExecutionOptions jdbcExecutionOptions = JdbcExecutionOptions.builder()
                .withBatchIntervalMs(200)             // optional: 默认为0，基于时间定时向 MySQL 中写入数据
                .withBatchSize(1000)                  // optional: 默认为5000，基于数据条数向 MySQL 中写入数据
                .withMaxRetries(5)                    // optional: 默认为3，出错后尝试次数
                .build();
        return JdbcSink.sink("insert into test_result(mid, value, ts) values(?,?,?)",
                jdbcStatementBuilder,
                jdbcExecutionOptions,
                connectionOptions
        );
    }

    /**
     * 构建数据源
     *
     * @return 数据源
     */
    private static RMQSource<SensorReading> buildSource() {
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
}
