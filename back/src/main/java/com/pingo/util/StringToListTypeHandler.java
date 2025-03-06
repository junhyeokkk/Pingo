package com.pingo.util;

import org.apache.ibatis.type.BaseTypeHandler;
import org.apache.ibatis.type.JdbcType;
import java.sql.*;
import java.util.Arrays;
import java.util.List;

public class StringToListTypeHandler extends BaseTypeHandler<List<String>> {

    @Override
    public void setNonNullParameter(PreparedStatement ps, int i, List<String> parameter, JdbcType jdbcType) throws SQLException {
        ps.setString(i, String.join(",", parameter));
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, String columnName) throws SQLException {
        String images = rs.getString(columnName);
        return images == null || images.isEmpty() ? List.of() : Arrays.asList(images.split(","));
    }

    @Override
    public List<String> getNullableResult(ResultSet rs, int columnIndex) throws SQLException {
        String images = rs.getString(columnIndex);
        return images == null || images.isEmpty() ? List.of() : Arrays.asList(images.split(","));
    }

    @Override
    public List<String> getNullableResult(CallableStatement cs, int columnIndex) throws SQLException {
        String images = cs.getString(columnIndex);
        return images == null || images.isEmpty() ? List.of() : Arrays.asList(images.split(","));
    }
}
