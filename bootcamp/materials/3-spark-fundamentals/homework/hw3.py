from pyspark.sql import SparkSession
from pyspark.sql.functions import expr, col
spark = SparkSession.builder.appName("Jupyter").getOrCreate()

spark
# Disable automatic broadcast joins
spark.conf.set("spark.sql.autoBroadcastJoinThreshold", "-1")