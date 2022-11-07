package com.esteel.streaming.kafka.e1;

import lombok.Data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author Kehaw
 * @since 2022/10/31
 */
@Data
public class MysqlDataMapping {

    public static final String OP = "__op";
    public static final String TABLE = "__table";
    public static final String SOURCE_MS = "__source_ts_ms";
    public static final String DELETED = "__deleted";

    private Schema schema = new Schema();

    private Map<String, Object> payload = new HashMap<>();

    @Data
    public static final class Schema {
        private String type;

        private List<Field> fields = new ArrayList<>();

        private String optional;

        private String name;

        @Data
        public static final class Field {
            private String type;

            private String optional;

            private String field;
        }
    }
}
