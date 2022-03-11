<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" omit-xml-declaration="yes" indent="no" encoding="utf-8"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="rule_303">
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">303</xsl:variable>
		<xsl:variable name="rule_name">Check &lt;label&gt; of book-part-meta/title-group.</xsl:variable>
		<xsl:variable name="error_type">warning</xsl:variable>
		
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
			
			<xsl:for-each select=".//book-part[./book-part-meta/title-group/label]">
				<xsl:choose>
					<xsl:when test="./book-part-meta[1]/title-group[1]/label[matches(lower-case(.),'(^[0-9\.]+$|^[ivxlcdm\.\(\)]+$|^[a-z\.\(\)]$|^xyz$)', 'i')]">
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class">pass</xsl:attribute>
								<xsl:text>pass</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:when>
					<xsl:otherwise>
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="warning">
								&lt;<xsl:value-of select="local-name()"/>
								<xsl:for-each select="./@*[not(local-name()=('lang', 'indexed', 'pageref', 'printqv', 'type'))]">
									<xsl:text> </xsl:text>
									<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"
								</xsl:for-each>&gt; – book-part/book-part-meta/title-group/label does not match expected pattern ("<xsl:value-of select="./book-part-meta[1]/title-group[1]/label"/>")</td>
						</tr>
					</xsl:otherwise>
				</xsl:choose>
			
			
			<!-- queried -->
			<!--<xsl:for-each select=".//book-part[@book-part-type=('chapter', 'entry', 'essay', 'lesson', 'letter', 'module', 'part', 'section', 'topic', 'unit')]">
				<xsl:choose>
					<xsl:when test="./book-part-meta[1]/title-group[1]/label[matches(.,'(chapter|entry|essay|lesson|letter|module|part|section|topic|unit)', 'i')]">
						<tr>
							<xsl:copy-of select="$rule_details"/>
							<td class="warning">
								&lt;<xsl:value-of select="local-name()"/>
								<xsl:for-each select="./@*[not(local-name()=('lang', 'indexed', 'pageref', 'printqv', 'type'))]">
									<xsl:text> </xsl:text>
									<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"
								</xsl:for-each>&gt; – book-part/book-part-meta/title-group/label should match keyword ('chapter', 'entry', 'essay', 'lesson', 'letter', 'module', 'part', 'section', 'topic', 'unit')</td>
						</tr>
					</xsl:when>
					<xsl:otherwise>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class">pass</xsl:attribute>
								<xsl:text>pass</xsl:text>
							</xsl:element>
						</xsl:element>
					</xsl:otherwise>
				</xsl:choose>-->

				
			<!--	<xsl:choose>
					<xsl:when test="./@book-part-number and ./@book-part-type='letter'">
						<xsl:choose>
							<xsl:when test="matches(lower-case(./@book-part-number),'(^[0-9\.]+$|^[ivxlcdm\.\(\)]+$|^[a-z\.\(\)]$|^xyz$)')"/>
							<xsl:otherwise>
								<tr>
									<xsl:copy-of select="$rule_details"/>
									<td class="warning">
								&lt;<xsl:value-of select="local-name()"/>
										<xsl:for-each select="./@*[not(local-name()=('lang', 'indexed', 'pageref', 'printqv', 'type'))]">
											<xsl:text> </xsl:text>
											<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"
										</xsl:for-each>&gt; – book-part-number attribute doesn't match list</td>
								</tr>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					<xsl:when test="./@book-part-number">
						<xsl:choose>
							<xsl:when test="matches(lower-case(./@book-part-number),'(^[0-9\.\(\)]+$|^[ivxlcdm\.\(\)]+$|^[a-z\.\(\)]$)')"/>
							<xsl:otherwise>
								<tr>
									<xsl:copy-of select="$rule_details"/>
									<td class="warning">
								&lt;<xsl:value-of select="local-name()"/>
										<xsl:for-each select="./@*[not(local-name()=('lang', 'indexed', 'pageref', 'printqv', 'type'))]">
											<xsl:text> </xsl:text>
											<xsl:value-of select="local-name()"/>="<xsl:value-of select="."/>"
										</xsl:for-each>&gt; – book-part-number attribute doesn't match list</td>
								</tr>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
				</xsl:choose>
			-->
			</xsl:for-each>
		</xsl:variable>

		<!-- DISPLAY RESULTS -->
		<xsl:call-template name="display_result">
			<xsl:with-param name="result" select="$result"/>
			<xsl:with-param name="rule_details" select="$rule_details"/>
		</xsl:call-template>
	</xsl:template>

</xsl:stylesheet>