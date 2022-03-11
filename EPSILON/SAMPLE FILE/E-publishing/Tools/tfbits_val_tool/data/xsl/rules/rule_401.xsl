<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_401" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">401</xsl:variable>
		<xsl:variable name="rule_name">Validate XML file name.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>
		<!--
		
		-->
		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:element name="td">
				<xsl:element name="span">
					<xsl:attribute name="class">rule</xsl:attribute>
					<xsl:text>Rule </xsl:text>
					<xsl:value-of select="$rule_number"/>
				</xsl:element>
				<xsl:text>: </xsl:text>
				<xsl:value-of select="$rule_name"/>
			</xsl:element>
		</xsl:variable>
		<!--
		
		-->
		<!-- SET VARIABLES AND DO RULE TESTING AND PROCESSING -->
		<!--
		
		-->
		<!-- tokenize document path -->
		<xsl:variable name="tokenized_string" select="tokenize(base-uri(),'[/\\]')"/>
		<!--
		
		-->
		<!-- split out tokenized document path and tag -->
		<xsl:variable name="tokenized_tagged">
			<xml>
				<xsl:for-each select="$tokenized_string">
					<tag>
						<xsl:value-of select="."/>
					</tag>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- get filename -->
		<xsl:variable name="filename" select="$tokenized_tagged//tag[last()]"/>
		<!--
		
		-->
		<!-- get isbn from filename -->
		<xsl:variable name="filename_isbn" select="$tokenized_tagged//tag[last()]/substring-before(.,'.')"/>
		<!--
		
		-->
		<!-- get filename extention -->
		<xsl:variable name="filename_ext" select="$tokenized_tagged//tag[last()]/substring-after(.,'.')"/>
		<!--
		
		-->
		<!-- validate ISBN in filename -->
		<xsl:variable name="validation_test">
			<xsl:analyze-string select="$filename_isbn" regex="(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)(\d)">
				<xsl:matching-substring>
					<!-- Length: <xsl:value-of select="string-length($myPassedISBN)"/>-->
					<xsl:variable name="base">
						<xsl:value-of select="(number(regex-group(1))*1)
     +
     (number(regex-group(2))*3)
     +
     (number(regex-group(3))*1)
     +
     (number(regex-group(4))*3)
     +
     (number(regex-group(5))*1)
     +
     (number(regex-group(6))*3)
     +
     (number(regex-group(7))*1)
     +
     (number(regex-group(8))*3)
     +
     (number(regex-group(9))*1)
     +
     (number(regex-group(10))*3)
     +
     (number(regex-group(11))*1)
     +
     (number(regex-group(12))*3)
     "/>
					</xsl:variable>
					<xsl:variable name="checkDigit" select="number(regex-group(13))"/>
					<xsl:variable name="remainder" select="10-(number($base mod 10))"/>
					<xsl:choose>
						<xsl:when test="$remainder eq $checkDigit">
							<xsl:text>valid</xsl:text>
						</xsl:when>
						<xsl:when test="$remainder = 10 and $checkDigit = 0">
							<xsl:text>valid</xsl:text>
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>invalid</xsl:text>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:matching-substring>
			</xsl:analyze-string>
		</xsl:variable>
		<!--
		
		-->
		<!-- find errors -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:if test="$validation_test = 'invalid'">
					<hit type="invalid_isbn"/>
				</xsl:if>
				<xsl:if test="not(replace($filename_isbn,'\d','') = '')">
					<hit type="invalid_chrs"/>
				</xsl:if>
				<xsl:if test="not(string-length(replace($filename_isbn,'[^0-9]',''))=13)">
					<hit type="invalid_length"/>
				</xsl:if>
				<xsl:if test="not($filename_ext = 'xml')">
					<hit type="invalid_ext"/>
				</xsl:if>
			</xml>
		</xsl:variable>
		<!--
		
		-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="count($hit_list//hit) = 0">
					<xsl:element name="tr">
						<xsl:copy-of select="$rule_details"/>
						<xsl:element name="td">
							<xsl:attribute name="class">pass</xsl:attribute>
							<xsl:text>pass</xsl:text>
						</xsl:element>
					</xsl:element>
				</xsl:when>
				<xsl:otherwise>
					<xsl:for-each select="$hit_list//hit[@type='invalid_isbn']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>ISBN used in filename is not a valid ISBN 13: </xsl:text>
								<xsl:value-of select="$filename_isbn"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="$hit_list//hit[@type='invalid_chrs']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>ISBN used in filename contains non-numeric characters: </xsl:text>
								<xsl:value-of select="$filename_isbn"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="$hit_list//hit[@type='invalid_length']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>ISBN used in filename is not 13 digits: </xsl:text>
								<xsl:value-of select="$filename_isbn"/>
								<xsl:text> (</xsl:text>
								<xsl:value-of select="string-length($filename_isbn)"/>
								<xsl:text> digits)</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
					<xsl:for-each select="$hit_list//hit[@type='invalid_ext']">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>File extention is not '.xml': </xsl:text>
								<xsl:value-of select="$filename_ext"/>
							</xsl:element>
						</xsl:element>
					</xsl:for-each>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--
		
		-->
		<!-- DISPLAY RESULTS -->
		<xsl:copy-of select="$result"/>
		<!--
		
		-->
	</xsl:template>
</xsl:stylesheet>
