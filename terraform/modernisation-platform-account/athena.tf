resource "aws_athena_workgroup" "mod_platform" {
  name        = "modernisation-platform"
  state       = "ENABLED"
  description = "Athena Workgroup for CSV queries"

  configuration {
    result_configuration {
      output_location = "s3://${module.member_information_bucket.bucket.bucket}/query-results/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }
}

resource "aws_glue_catalog_database" "member_information" {
  name = "member_information_db"
}

resource "aws_glue_catalog_table" "member_information" {
  name          = "member_information"
  database_name = aws_glue_catalog_database.member_information.name
  table_type    = "EXTERNAL_TABLE"

  storage_descriptor {
    columns {
      name = "accountname"
      type = "string"
    }
    columns {
      name = "awsaccountid"
      type = "string"
    }
    columns {
      name = "slackchannel"
      type = "string"
    }
    columns {
      name = "infrastructuresupportemail"
      type = "string"
    }
    columns {
      name = "incidenthours"
      type = "string"
    }
    columns {
      name = "incidentcontactdetails"
      type = "string"
    }
    columns {
      name = "serviceurls"
      type = "string"
    }

    ser_de_info {
      name                  = "CSV Serde"
      serialization_library = "org.apache.hadoop.hive.serde2.lazy.LazySimpleSerDe"
      parameters = {
        "separatorChar"          = ","
        "quoteChar"              = "\""
        "field.delim"            = ","
        "skip.header.line.count" = "1"
        "escapeChar"             = "\\"
      }
    }

    location      = "s3://${module.member_information_bucket.bucket.bucket}/data/"
    input_format  = "org.apache.hadoop.mapred.TextInputFormat"
    output_format = "org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat"
  }
}
