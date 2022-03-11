<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	

	<xsl:template name="rule_818">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">818</xsl:variable>
		<xsl:variable name="rule_name">Check content of &lt;year&gt;.</xsl:variable>
		<xsl:variable name="error_type">fail</xsl:variable>
		
		<!-- DISPLAY MESSAGE -->
		<xsl:call-template name="message">
			<xsl:with-param name="rule_number" select="$rule_number"/>
		</xsl:call-template>

		<!-- SET GENERIC RULE DETAILS TEXT -->
		<xsl:variable name="rule_details">
			<xsl:call-template name="rule_details">
				<xsl:with-param name="rule_number" select="$rule_number"/>
				<xsl:with-param name="rule_name" select="$rule_name"/>
			</xsl:call-template>
		</xsl:variable>

		<!-- DETERMINE RESULTS TEXT -->
		<xsl:variable name="result">
			<xsl:for-each select=".//ref//year">
				<xsl:variable name="year" select="."/>
				<xsl:variable name="year" select="replace($year,'/','')"/>
				<xsl:variable name="year" select="replace($year,'–','')"/>
				<xsl:variable name="year" select="replace($year,'BCE','')"/>
				<xsl:variable name="year" select="replace($year,'CE','')"/>
				<xsl:variable name="year" select="replace($year,'BC','')"/>
				<xsl:variable name="year" select="replace($year,'AD','')"/>
				<xsl:variable name="year" select="replace($year,'AH','')"/>
				<xsl:choose>
					<xsl:when test="string(number($year))='NaN'">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">year in reference: id="<xsl:value-of select="ancestor::ref/@id"/>" – "<xsl:value-of select="."/>" is not a valid year</td>
						</tr>
					</xsl:when>
					<xsl:otherwise/>
				</xsl:choose>
			</xsl:for-each>
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
