package com.esteel.streaming.rabbitmq;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.math.BigDecimal;

/**
 * @author Kehaw
 * @since 2022/10/14
 */
@Data
public class SensorReading {

    @JsonProperty("$id")
    private String id;

    @JsonProperty("$createdAt")
    private long createdAt;

    private long metricId;

    private BigDecimal metricValue;

    private long metricTime;

    @JsonProperty("$type")
    private String type;
}
