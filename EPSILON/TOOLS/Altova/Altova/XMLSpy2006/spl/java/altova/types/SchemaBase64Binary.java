/**
 * SchemaBase64Binary.java
 *
 * This file was generated by [=$Host].
 *
 * YOU SHOULD NOT MODIFY THIS FILE, BECAUSE IT WILL BE
 * OVERWRITTEN WHEN YOU RE-RUN CODE GENERATION.
 *
 * Refer to the [=$HostShort] Documentation for further details.
 * [=$HostURL]
 */


package com.altova.types;


public class SchemaBase64Binary extends SchemaBinaryBase {
  // construction
  public SchemaBase64Binary() {
    super();
  }

  public SchemaBase64Binary(SchemaBase64Binary newvalue) {
    value = newvalue.value;
    isempty = newvalue.isempty;
    isnull = newvalue.isnull;
  }

  public SchemaBase64Binary(byte\[\] newvalue) {
    setValue( newvalue );
  }
[if $DBLibraryCount > 0]
  public SchemaBase64Binary(java.sql.ResultSet rst, String colname) throws java.sql.SQLException {
    setValue(rst.getBytes(colname));
	isnull = rst.wasNull();
  }
[endif]
  public SchemaBase64Binary(String newvalue) {
    parse( newvalue );
  }

  public SchemaBase64Binary(SchemaType newvalue) {
    assign( newvalue );
  }

  public SchemaBase64Binary(SchemaTypeBinary newvalue) {
    assign( (SchemaType)newvalue );
  }

  // getValue, setValue
  public void parse(String newvalue) {
    if( newvalue == null )
      setNull();
    else if( newvalue.length() == 0)
      setEmpty();
    else {
      setNull();
	  try {
	    value = new sun.misc.BASE64Decoder().decodeBuffer(newvalue);
        isnull = false;
        isempty = ( value.length == 0 ) ? true : false;
	  }
	  catch( java.io.IOException e ) {
		value = null;
	  }
    }
  }

  // further
  public int hashCode() {
    return value.hashCode();
  }

  public boolean equals(Object obj) {
    if (! (obj instanceof SchemaBase64Binary))
      return false;
    return value.equals(( (SchemaBase64Binary) obj).value);
  }

  public Object clone() {
    return new SchemaBase64Binary( this );
  }

  public String toString() {
    if( isempty || isnull || value == null )
      return "";
    String sResult = new sun.misc.BASE64Encoder().encode(value);
	return sResult.replaceAll( "\\r", "" );
  }

  // ---------- interface SchemaTypeBinary ----------
  public int binaryType() {
	  return BINARY_VALUE_BASE64;
  }
}