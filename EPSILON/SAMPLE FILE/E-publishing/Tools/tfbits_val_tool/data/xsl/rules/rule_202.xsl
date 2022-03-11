<?xml version="1.0" encoding="UTF-8"?>
<!--Book frontmatter
The following table presents validation rules pertaining to book frontmatter (in TFB XML, matter within the <book-front> element).
202 	Dedication check. 	Dedication must be tagged <notes notes-type="dedication"> rather than <sec sec-type="dedication"> 	Error
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_202">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">202</xsl:variable>
		<xsl:variable name="rule_name">Dedication check.</xsl:variable>
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
			<xsl:if test="/book/front-matter/front-matter-part[@book-part-type='dedication']">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">
							"<xsl:value-of select="/book/front-matter/front-matter-part[@book-part-type='dedication']"/>": Dedication tagged &lt;front-matter-part book-part-type="dedication"&gt; rather than &lt;dedication&gt;</td>
					</tr>
				</xsl:if>
			</xsl:variable>
		
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>
</xsl:stylesheet>