<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_506" match="*">
		<!--

	-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">506</xsl:variable>
		<xsl:variable name="rule_name">Check for minimum reference list citations.</xsl:variable>
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
		<!-- count references with ids that are not in further reading or bibliography -->
		<xsl:variable name="ref_count" select="count(//ref-list[count(ancestor::ref-list) = 0 and (not(contains(lower-case(./title),'further reading')) and not(contains(lower-case(./title),'bibliography')))]//ref[@id])"/>
		<!--

	-->
		<!-- create list of ref ids which are not in further reading or bibliography -->
		<xsl:variable name="ref_ids">
			<xml>
				<xsl:for-each select="//ref-list[count(ancestor::ref-list) = 0 and (not(contains(lower-case(./title),'further reading')) and not(contains(lower-case(./title),'bibliography')))]//ref/@id">
					<id>
						<xsl:value-of select="."/>
					</id>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--

	-->
		<!-- create list of xref rids -->
		<xsl:variable name="ref_rids">
			<xml>
				<xsl:for-each select="//xref[@ref-type='bibr']/@rid">
					<rid>
						<xsl:value-of select="."/>
					</rid>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--

	-->
		<!-- create list of ref ids which are not cited-->
		<xsl:variable name="uncited_ref_ids">
			<xml>
				<xsl:for-each select="$ref_ids//id[not(. = $ref_rids//rid)]">
					<id>
						<xsl:value-of select="."/>
					</id>
				</xsl:for-each>
			</xml>
		</xsl:variable>
		<!--

	-->
		<!-- count uncited references -->
		<xsl:variable name="uncited_ref_count" select="count($uncited_ref_ids//id)"/>
		<!--

	-->
		<!-- calculate percentage of refs which are uncited -->
		<xsl:variable name="uncited_refs_percent">
			<xsl:choose>
				<xsl:when test="not($ref_count = 0)">
					<xsl:value-of select="round(((($ref_count - $uncited_ref_count) div $ref_count) * 10000)) div 100"/>
				</xsl:when>
				<xsl:otherwise>0</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--

	-->
		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:choose>
				<xsl:when test="not($uncited_refs_percent > 75) and not($ref_count = 0)">Fewer than 75% of references are cited<!-- (<xsl:value-of select="$ref_count - $uncited_ref_count"/> out of <xsl:value-of select="$ref_count"/> references are cited &#x2013; <xsl:value-of select="$uncited_refs_percent"/>%)-->.</xsl:when>
				<xsl:otherwise>pass</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--

	-->
		<!-- DISPLAY RESULTS -->
		<xsl:choose>
			<!--
			
			-->
			<!-- display pass -->
			<xsl:when test="$result = 'pass'">
				<xsl:element name="tr">
					<xsl:copy-of select="$rule_details"/>
					<xsl:element name="td">
						<xsl:attribute name="class">pass</xsl:attribute>
						<xsl:copy-of select="$result"/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<!--
			
			-->
			<!-- display warning/fail -->
			<xsl:otherwise>
				<xsl:element name="tr">
					<xsl:copy-of select="$rule_details"/>
					<xsl:element name="td">
						<xsl:attribute name="class" select="$error_type"/>
						<xsl:copy-of select="$result"/>
					</xsl:element>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		<!--
		
		-->
	</xsl:template>
</xsl:stylesheet>
