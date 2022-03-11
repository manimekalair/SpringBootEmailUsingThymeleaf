<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_835" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">835</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged &lt;fpage&gt; and &lt;lpage&gt; elements.</xsl:variable>
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
				<!--
				-->
				<!-- select each mixed-citation -->
				<xsl:for-each select="//mixed-citation">
					<!--
					-->
					<!-- set pub-type variable -->
					<xsl:variable name="pub-type" select="./@publication-type"/>
					<!--
					-->
					<!-- test when pub-type is book, journal, or newspaper -->
					<xsl:choose>
						<xsl:when test="$pub-type = 'book' or $pub-type = 'journal' or $pub-type = 'newspaper'">
							<xsl:choose>
								<!--
								-->
								<!-- test for page range when there is no fpage and no lpage -->
								<xsl:when test="not(.//fpage) and not(.//lpage)">
									<xsl:variable name="text">
										<text>
											<xsl:value-of select="."/>
										</text>
									</xsl:variable>
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
									<xsl:analyze-string select="string-join(text(),'/*')" regex="(\d+)(–|—|—|‒|―|⸺|⸻|-|‐|−)(\d+)">
										<xsl:matching-substring>
											<hit type="range">
												<found>
													<xsl:value-of select="regex-group(1)"/>
													<xsl:value-of select="regex-group(2)"/>
													<xsl:value-of select="regex-group(3)"/>
												</found>
												<pub-type>
													<xsl:value-of select="$pub-type"/>
												</pub-type>
												<xsl:copy-of select="$text"/>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:matching-substring>
									</xsl:analyze-string>
								</xsl:when>
								<!--
								-->
								<!-- test when there is an fpage but no lpage -->
								<xsl:when test=".//fpage and not(.//lpage)">
									<xsl:variable name="text">
										<text>
											<xsl:value-of select="."/>
										</text>
									</xsl:variable>
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
									<!--
									-->
									<!-- run test for each fpage (that has following text else we get a Saxon zero-length string error) -->
									<xsl:for-each select=".//fpage[./following-sibling::text()[1]]">
										<xsl:variable name="fpage" select="."/>
										<xsl:variable name="following-text" select="following-sibling::text()[1]"/>
										<xsl:analyze-string select="$following-text" regex="^(–|—|—|‒|―|⸺|⸻|-|‐|−)(\d+)">
											<xsl:matching-substring>
												<hit type="no-lpage">
													<found>
														<xsl:value-of select="regex-group(1)"/>
														<xsl:value-of select="regex-group(2)"/>
													</found>
													<fpage>
														<xsl:value-of select="$fpage"/>
													</fpage>
													<pub-type>
														<xsl:value-of select="$pub-type"/>
													</pub-type>
													<xsl:copy-of select="$text"/>
													<xsl:copy-of select="$location"/>
												</hit>
											</xsl:matching-substring>
										</xsl:analyze-string>
									</xsl:for-each>
								</xsl:when>
							</xsl:choose>
						</xsl:when>
					</xsl:choose>
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
						<xsl:sort select="./@type" order="ascending"/>
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible untagged </xsl:text>
								<xsl:if test="./@type = 'range'">
									<xsl:text>page range</xsl:text>
								</xsl:if>
								<xsl:if test="./@type = 'no-lpage'">
									<xsl:text>last page</xsl:text>
								</xsl:if>
								<xsl:text> in </xsl:text>
								<xsl:value-of select="./pub-type"/>
								<xsl:text> reference ("</xsl:text>
								<xsl:if test="./@type = 'range'">
									<xsl:value-of select="./found"/>
								</xsl:if>
								<xsl:if test="./@type = 'no-lpage'">
									<xsl:text>&lt;fpage&gt;</xsl:text>
									<xsl:value-of select="./fpage"/>
									<xsl:text>&lt;/fpage&gt;</xsl:text>
									<xsl:value-of select="./found"/>
								</xsl:if>
								<xsl:text>") – "</xsl:text>
								<xsl:value-of select="./text"/>
								<xsl:text>" (</xsl:text>
								<xsl:if test="./location/@type = 'xpath'">
									<xsl:text>at: </xsl:text>
								</xsl:if>
								<xsl:if test="./location/@type = 'element'">
									<xsl:text>in: </xsl:text>
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
</xsl:stylesheet>
