/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.esteel.streaming.kafka.e1;

import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.api.common.restartstrategy.RestartStrategies;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.util.Objects;
import java.util.concurrent.TimeUnit;

/**
 * @author Kehaw
 * @since JDK11
 */
public class KafkaStreamingJob {

    public static void main(String[] args) throws Exception {
        // 定义流式计算的环境
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();

        // 配置失败重启策略
        env.setRestartStrategy(RestartStrategies.fixedDelayRestart(
                Integer.MAX_VALUE, // 尝试重启的次数
                org.apache.flink.api.common.time.Time.of(10, TimeUnit.SECONDS) // 间隔
        ));

        KafkaSource<MysqlDataMapping> source = buildSource();
        DataStream<MysqlDataMapping> stream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka source");
        stream.rebalance().filter(Objects::nonNull).map((MapFunction<MysqlDataMapping, Object>) value -> "Received message: " + value).print();
        // execute program
        env.execute("Flink Streaming Java API Skeleton");
    }

    private static KafkaSource<MysqlDataMapping> buildSource() {
        return KafkaSource.<MysqlDataMapping>builder()
                .setBootstrapServers("10.0.170.197:9092")
                .setTopics("mysql2.esteel_test.test")
                .setGroupId("my-test-group")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new TableDataDeserializationSchema())
                .build();
    }
}
