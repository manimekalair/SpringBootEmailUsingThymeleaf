<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_501" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">501</xsl:variable>
		<xsl:variable name="rule_name">Check citations are tagged &lt;xref&gt;.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<!-- select text in all non-xref elements with no descendants -->
				<!--<xsl:for-each select="//*[not(ancestor-or-self::xref|self::label|ancestor::ref)]/text()[not(descendant::*)]">-->
				<xsl:for-each select="//*[not(ancestor-or-self::xref|self::label|ancestor::ref)]/text()">
					<!-- pass location of element to variable -->
					<xsl:variable name="location">
						<location>
							<xsl:choose>
								<xsl:when test="./ancestor-or-self::*[@id][1]">
									<xsl:attribute name="type">element</xsl:attribute>
									<xsl:text>&lt;</xsl:text>
									<xsl:value-of select="name(./ancestor-or-self::*[@id][1])"/>
									<xsl:text> id="</xsl:text>
									<xsl:value-of select="./ancestor-or-self::*[@id][1]/@id"/>
									<xsl:text>"&gt;</xsl:text>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="type">xpath</xsl:attribute>
									<xsl:for-each select="ancestor::*">
										<xsl:text>/</xsl:text>
										<xsl:value-of select="name()"/>
									</xsl:for-each>
									<xsl:text>/</xsl:text>
									<xsl:value-of select="name()"/>
								</xsl:otherwise>
							</xsl:choose>
						</location>
					</xsl:variable>
					<!-- test if the string contains a possible untagged table xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Tt]able)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="table">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if the string contains a possible untagged figure xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Ff]igure|[Pp]late|[Mm]ap|[Gg]raph)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="figure">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if the string contains a possible untagged box xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Bb]ox)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="box">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if the string contains a possible untagged book-part xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Cc]hapter|[Pp]art|[Ss]ection)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="book-part">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if the string contains a possible untagged equation xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Ee]quation|[Ff]ormula)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="equation">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!-- test if the string contains a possible untagged page xref and if so create a hit for the list-->
					<xsl:analyze-string select="." regex="(.*[^A-Za-z]|^)([Pp]age)(\s+[A-Z\.]*[0-9\.]+)(.*)">
						<xsl:matching-substring>
							<hit type="equation">
								<xsl:call-template name="hit_details"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
				</xsl:for-each>
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
					<xsl:for-each select="$hit_list//hit">
						<xsl:sort select="./@type" order="ascending"/>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible untagged </xsl:text>
								<xsl:value-of select="@type"/>
								<xsl:text> citation: "</xsl:text>
								<xsl:value-of select="./pre"/>
								<xsl:element name="u">
									<xsl:value-of select="./ref"/>
								</xsl:element>
								<xsl:value-of select="./post"/>
								<xsl:text>" (</xsl:text>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
								<xsl:text>).</xsl:text>
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
	<!--
		
	-->
	<!-- template for inserting report details into hit list -->
	<xsl:template name="hit_details">
		<ref>
			<xsl:value-of select="regex-group(2)"/>
			<xsl:value-of select="regex-group(3)"/>
		</ref>
		<pre>
			<xsl:choose>
				<xsl:when test="string-length(regex-group(1)) lt 30">
					<xsl:value-of select="regex-group(1)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>... </xsl:text>
					<xsl:value-of select="substring(regex-group(1),string-length(regex-group(1)) - 30,string-length(regex-group(1)))"/>
				</xsl:otherwise>
			</xsl:choose>
		</pre>
		<post>
			<xsl:choose>
				<xsl:when test="string-length(regex-group(4)) lt 30">
					<xsl:value-of select="regex-group(4)"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="substring(regex-group(4),0,30)"/>
					<xsl:text> ...</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</post>
	</xsl:template>
</xsl:stylesheet>
