<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="yes" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>
	<!--Sion Refactor -->
	<xsl:template name="rule_001">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">001</xsl:variable>
		<xsl:variable name="rule_name">Check for mandatory elements.</xsl:variable>
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
			<!-- <xsl:if test="not(/book/book-meta//edition 
				and /book/book-meta//impression 
				and /book/book-meta//contrib-group 
				and /book/book-meta//isbn 
				and /book/book-meta//pub-date 
				and /book/book-meta//permissions 
				and /book/book-meta//copyright-statement 
				and /book/book-meta//copyright-year 
				and /book/book-meta//copyright-holder 
				and /book/book-meta/notes[@notes-type='imprint-page'] 
				and /book/book-meta//counts 
				and /book/book-meta//fig-count 
				and /book/book-meta//table-count 
				and /book/book-meta//page-count 
				and /book/book-meta//notes[@notes-type='supplier'])"> -->
			<!--Sion we don't need this wrapper as we are performing test twice then! <xsl:if test="not(/book/book-meta//edition 
				and /book/book-meta//contrib-group 
				and /book/book-meta//isbn 
				and /book/book-meta//permissions 
				and /book/book-meta//copyright-statement 
				and /book/book-meta//copyright-year 
				and /book/book-meta//copyright-holder 
				and /book/book-meta/notes[@notes-type='imprint-page'] 
				and /book/book-meta//notes[@notes-type='supplier'])">-->
			<!--Crap<xsl:if test="not(/book/book-meta//edition)">-->
			<xsl:if test="not(/book/book-meta/edition)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;edition&gt; missing</td>
				</tr>
			</xsl:if>
			<!-- Sion refactor <xsl:if test="not(/book/book-meta//impression)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;impression&gt; missing</td>
					</tr>
				</xsl:if> -->
			<xsl:if test="not(/book/book-meta/contrib-group)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;contrib-group&gt; missing</td>
				</tr>
			</xsl:if>
			<xsl:if test="not(/book/book-meta/publisher)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;publisher&gt; missing</td>
				</tr>
			</xsl:if>
			<!--Scrub<xsl:if test="not(/book/book-meta//publisher-name)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;publisher-name&gt; missing</td>
					</tr>
				</xsl:if>
				<xsl:if test="not(/book/book-meta//publisher-loc)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;publisher-loc&gt; missing</td>
					</tr>
				</xsl:if>-->
			<xsl:if test="not(/book/book-meta/isbn)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;isbn&gt; missing</td>
				</tr>
			</xsl:if>
			<!-- Sion no longer required <xsl:if test="not(/book/book-meta//pub-date)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;pub-date&gt; missing</td>
					</tr>
				</xsl:if>-->
			<xsl:if test="not(/book/book-meta/permissions)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;permissions&gt; missing</td>
				</tr>
			</xsl:if>
			<xsl:if test="not(/book/book-meta/permissions/copyright-statement)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;copyright-statement&gt; missing</td>
				</tr>
			</xsl:if>
			<xsl:if test="not(/book/book-meta/permissions/copyright-year)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;copyright-year&gt; missing</td>
				</tr>
			</xsl:if>
			<xsl:if test="not(/book/book-meta/permissions/copyright-holder)">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;copyright-holder&gt; missing</td>
				</tr>
			</xsl:if>
			<!-- new form -->
			<xsl:if test="not(/book/book-meta/notes[@notes-type = 'imprint-page'])">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;notes notes-type="imprint-page"&gt;
						missing</td>
				</tr>
			</xsl:if>
			<!--Sion remove <xsl:if test="not(/book/book-meta//counts)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;counts&gt; missing</td>
					</tr>
				</xsl:if>
				<xsl:if test="not(/book/book-meta//fig-count)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;fig-count&gt; missing</td>
					</tr>
				</xsl:if>
				<xsl:if test="not(/book/book-meta//table-count)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;table-count&gt; missing</td>
					</tr>
				</xsl:if>
				<xsl:if test="not(/book/book-meta//page-count)">
					<tr>
						<xsl:copy-of select="$rule_details"/>
						<td class="fail">Mandatory element &lt;page-count&gt; missing</td>
					</tr>
				</xsl:if>-->
			<xsl:if test="not(/book/book-meta/notes[@notes-type = 'supplier'])">
				<tr>
					<xsl:copy-of select="$rule_details"/>
					<td class="fail">Mandatory element &lt;notes note-type="supplier"&gt;
						missing</td>
				</tr>
			</xsl:if>
			<!--</xsl:if>-->
		</xsl:variable>
		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>
