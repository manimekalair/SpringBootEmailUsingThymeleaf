<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:xlink="http://www.w3.org/1999/xlink">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_608" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">608</xsl:variable>
		<xsl:variable name="rule_name">Cross-check artwork file names with labels.</xsl:variable>
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
		<!-- build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<!--
				-->
				<xsl:for-each select="//graphic">
					<!--
					-->
					<xsl:choose>
						<xsl:when test="parent::fig/label">
							<xsl:variable name="test-filename" select="substring(@xlink:href,1,3)"/>
							<xsl:variable name="test-label" select="substring(lower-case(parent::fig/label/text()[matches(., '\w')]),1,3)"/>
							<xsl:choose>
								<!-- discard when label starts with a number -->
								<xsl:when test="matches($test-label,'^[0-9]')"/>
								<!-- discard when filename prefix matches what is expected -->
								<xsl:when test="$test-filename = $test-label"/>
								<xsl:otherwise>
									<hit>
										<file>
											<text>
												<xsl:value-of select="@xlink:href"/>
											</text>
											<prefix>
												<xsl:value-of select="$test-filename"/>
											</prefix>
										</file>
										<label>
											<text>
												<xsl:value-of select="parent::fig/label/text()[matches(., '\w')]"/>
											</text>
											<prefix>
												<xsl:value-of select="$test-label"/>
											</prefix>
										</label>
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
									</hit>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
					<!--
					-->
				</xsl:for-each>
				<!--
				-->
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
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found mismatch between artwork file name (name: "</xsl:text>
								<xsl:value-of select="./file/text"/>
								<xsl:text>" &#x2013; prefix: "</xsl:text>
								<xsl:value-of select="./file/prefix"/>
								<xsl:text>") and label (text: "</xsl:text>
								<xsl:value-of select="./label/text"/>
								<xsl:text>" &#x2013; prefix: "</xsl:text>
								<xsl:value-of select="./label/prefix"/>
								<xsl:text>"). </xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>At: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>In: </xsl:text>
								</xsl:if>
								<xsl:value-of select="./location"/>
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
