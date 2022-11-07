package com.esteel.streaming.rabbitmq;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.serialization.AbstractDeserializationSchema;

import java.io.IOException;
import java.util.Objects;

/**
 * @author Kehaw
 * @since 2022/10/14
 */
public class SensorDeserializationSchema extends AbstractDeserializationSchema<SensorReading> {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public SensorReading deserialize(byte[] message) throws IOException {
        if (Objects.nonNull(message)) {
            return MAPPER.readValue(message, SensorReading.class);
        } else {
            return null;
        }
    }
}
