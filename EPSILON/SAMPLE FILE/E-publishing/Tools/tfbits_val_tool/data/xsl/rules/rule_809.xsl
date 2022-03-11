<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">	
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_809">
		<!-- Names in references
            Check whether a reference uses dash character(s) to replace the name of the author
       -->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">809</xsl:variable>
		<xsl:variable name="rule_name">Check for dashes substituting names.</xsl:variable>
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
			<xsl:for-each select=".//ref">
				<xsl:variable name="ref">
					<xsl:value-of select="normalize-space(.)"/>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="
(starts-with($ref,'–')) or 
(starts-with($ref,'—')) or 
(starts-with($ref,'—')) or 
(starts-with($ref,'‒')) or 
(starts-with($ref,'―')) or 
(starts-with($ref,'⸺')) or 
(starts-with($ref,'⸻')) or 
(starts-with($ref,'-')) or 
(starts-with($ref,'‐')) or 
(starts-with($ref,'−'))">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="fail">Author names replaced by dash characters: id="<xsl:value-of select="./@id"/>" "<xsl:value-of select="$ref"/>"</td>
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