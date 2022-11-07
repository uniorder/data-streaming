package com.esteel.streaming.kafka.e2;

import org.apache.flink.api.common.serialization.SimpleStringSchema;

import java.util.Objects;

/**
 * @author Kehaw
 * @since 2022/10/31
 */
public class MyStringSchema extends SimpleStringSchema {

    @Override
    public String deserialize(byte[] message) {
        if (Objects.isNull(message)) {
            return null;
        }
        return super.deserialize(message);
    }
}
