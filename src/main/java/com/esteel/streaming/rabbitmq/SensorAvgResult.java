package com.esteel.streaming.rabbitmq;

import lombok.Getter;
import lombok.Setter;
import org.apache.flink.table.annotation.DataTypeHint;

import java.math.BigDecimal;

/**
 * @author Kehaw
 * @since 2022/10/14
 */
@Getter
@Setter
public class SensorAvgResult {
    private Long mid;

    @DataTypeHint("DECIMAL(10, 2)")
    private BigDecimal avgValue;

    @Override
    public String toString() {
        return "平均值：{" +
                "mid=" + mid +
                ", avg=" + avgValue +
                '}';
    }
}
