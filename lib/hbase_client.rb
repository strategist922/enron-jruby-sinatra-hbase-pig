# Adapted from obsolete example at http://wiki.apache.org/hadoop/Hbase/JRuby

include Java
import org.apache.hadoop.hbase.HBaseConfiguration
import org.apache.hadoop.hbase.HColumnDescriptor
import org.apache.hadoop.hbase.HConstants
import org.apache.hadoop.hbase.HTableDescriptor
import org.apache.hadoop.hbase.client.HBaseAdmin
import org.apache.hadoop.hbase.client.HTable
import org.apache.hadoop.hbase.client.Get
import org.apache.hadoop.hbase.client.Put
import org.apache.hadoop.hbase.client.ResultScanner
import org.apache.hadoop.hbase.util.Writables
import org.apache.hadoop.hbase.util.Bytes
import org.apache.hadoop.io.Text

class HBaseClient
  
  attr_accessor :table
  
  def initialize()
    @table = nil
    @conf = nil
  end
  
  # Connect to HBase and our table
  def connect(table_name)
    @conf = HBaseConfiguration.create
    admin = HBaseAdmin.new(@conf)
    @table = HTable.new(@conf, table_name)
  end
  
  def get_key(key)
    my_get = Get.new(key.to_java_bytes)
    result = @table.get(my_get)
    result_ary = []
    for kv in result.list
      family = String.from_java_bytes(kv.get_family)
      qualifier = org.apache.hadoop.hbase.util.Bytes::toStringBinary(kv.get_qualifier)
      column = "#{family}:#{qualifier}"
      value = to_string(column, kv, -1)
      timestamp = kv.get_timestamp
      str_value = org.apache.hadoop.hbase.util.Bytes::toStringBinary(kv.get_value)
      result_ary << str_value.to_s
    end
    result_ary
  end
  
  # Make a String of the passed kv
  def to_string(column, kv, maxlength = -1)
    if kv.isDelete
      val = "timestamp=#{kv.getTimestamp}, type=#{org.apache.hadoop.hbase.KeyValue::Type::codeToType(kv.getType)}"
    else
      val = "timestamp=#{kv.getTimestamp}, value=#{org.apache.hadoop.hbase.util.Bytes::toStringBinary(kv.getValue)}"
    end
    val
  end
  
end