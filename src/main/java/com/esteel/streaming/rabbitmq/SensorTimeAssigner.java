package com.esteel.streaming.rabbitmq;

import org.apache.flink.api.common.eventtime.SerializableTimestampAssigner;

/**
 * @author Kehaw
 * @since 2022/10/14
 */
public class SensorTimeAssigner implements SerializableTimestampAssigner<SensorReading> {
    @Override
    public long extractTimestamp(SensorReading sensorReading, long l) {
        return sensorReading.getCreatedAt();
    }
}
