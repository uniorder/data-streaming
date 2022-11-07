package com.esteel.streaming.kafka.e3;

import org.apache.flink.streaming.connectors.kafka.table.KafkaConnectorOptions;
import org.apache.flink.table.api.*;

/**
 * @author Kehaw
 * @since 2022/10/28
 */
public class KafkaStreamingTableJob {
    public static void main(String[] args) {
        final EnvironmentSettings settings = EnvironmentSettings.inStreamingMode();

        TableEnvironment env = TableEnvironment.create(settings);

        Schema.Builder schemaBuilder = Schema.newBuilder();
        schemaBuilder.column("id", DataTypes.BIGINT())
                .column("value", DataTypes.STRING());

        TableDescriptor tableDescriptor = TableDescriptor.forConnector("kafka")
                .option(KafkaConnectorOptions.TOPIC.key(), "mysql.esteel_test.test")
                .option(KafkaConnectorOptions.PROPS_BOOTSTRAP_SERVERS, "10.0.170.197:9092")
                .option(KafkaConnectorOptions.PROPS_GROUP_ID, "my-test-group")
                .option(KafkaConnectorOptions.SCAN_STARTUP_MODE.key(), "earliest-offset")
                .option("properties.auto.offset.reset", "earliest")
                .format("debezium-json")
                .schema(schemaBuilder.build())
                .build();
        env.createTemporaryTable("esteel_test", tableDescriptor);
        Table table = env.sqlQuery("select sum(id)  from esteel_test");
        TableResult result = table.execute();
        result.print();
    }
}
