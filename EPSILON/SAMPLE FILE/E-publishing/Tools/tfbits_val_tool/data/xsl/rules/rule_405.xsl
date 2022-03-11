<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="things">

	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" exclude-result-prefixes="xlink"
		encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	
	<xsl:template name="rule_405">
		
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">405</xsl:variable>
		<xsl:variable name="rule_name">Check for mandatory page start &lt;target&gt; tags in &lt;title&gt; elements.</xsl:variable>
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
			<xsl:for-each select="/book/front-matter/(ack|glossary|notes|front-matter-part/book-part-meta/title-group)/title[not(.//target[@target-type='page'][@id])]
      |//book-part[not(@book-part-type='entry')]/book-part-meta/title-group/title[not(.//target[@target-type='page'][@id])]
      |/book/book-back/sec/title[not(.//target[@target-type='page'][@id])]
      |/book/book-back/notes/title[not(.//target[@target-type='page'][@id])]
      |/book/book-back/ref-list/title[not(.//target[@target-type='page'][@id])]
      |/book/book-back/app-group/app/title[not(.//target[@target-type='page'][@id])]">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Title "<em>
							<xsl:value-of select="."/>
						</em>": page start &lt;target&gt; missing (<xsl:for-each select="ancestor-or-self::*">
							<xsl:text>/</xsl:text>
							<xsl:value-of select="name()"/>
						</xsl:for-each>)</td>
				</tr>
			</xsl:for-each>
		</xsl:variable>
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
