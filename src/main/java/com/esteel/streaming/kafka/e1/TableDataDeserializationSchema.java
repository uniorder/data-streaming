package com.esteel.streaming.kafka.e1;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.serialization.AbstractDeserializationSchema;

import java.io.IOException;
import java.util.Objects;

/**
 * @author Kehaw
 * @since 2022/10/31
 */
public class TableDataDeserializationSchema extends AbstractDeserializationSchema<MysqlDataMapping> {

    private static final ObjectMapper MAPPER = new ObjectMapper();

    @Override
    public MysqlDataMapping deserialize(byte[] message) throws IOException {
        if (Objects.isNull(message)) {
            return null;
        }
        return MAPPER.readValue(message, MysqlDataMapping.class);
    }
}
