<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_509" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">509</xsl:variable>
		<xsl:variable name="rule_name">Check for missing reference citation tagging.</xsl:variable>
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
		<!-- build unfiltered hit list -->
		<xsl:variable name="hit_list_unfiltered">
			<xml>
				<!--
				-->
				<xsl:for-each select="//text()">
					<!--
					-->
					<xsl:choose>
						<!-- discard text depending on ancestor -->
						<xsl:when test="ancestor-or-self::book-meta"/>
						<xsl:when test="ancestor-or-self::ref"/>
						<xsl:when test="ancestor-or-self::bio"/>
						<xsl:when test="ancestor-or-self::xref[@ref-type = 'bibr']"/>
						<xsl:otherwise>
							<!-- set variables for reporting -->
							<xsl:variable name="text">
								<text>
									<xsl:value-of select="."/>
								</text>
							</xsl:variable>
							<!--
							-->
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
							<!-- Iterate through regex matches for common reference citation patterns -->
							<!--
							-->
							<!-- find Surname, Surname, Surname (and / & / with) Surname,? 0000 -->
							<xsl:analyze-string select="." regex="([A-Z][^\s]+,\s+[A-Z][^\s]+,\s+[A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+,?\s+\d\d\d\d[a-z]*)[^&#x2013;]">
								<xsl:matching-substring>
									<hit>
										<found>
											<xsl:value-of select="regex-group(1)"/>
											<xsl:value-of select="regex-group(2)"/>
											<xsl:value-of select="regex-group(3)"/>
										</found>
										<preceding-text>
											<xsl:value-of select="substring-before($text,regex-group(1))"/>
										</preceding-text>
										<following-text>
											<xsl:value-of select="substring-after($text,regex-group(3))"/>
										</following-text>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<!--
									-->
									<!-- find Surname, Surname, Surname (and / & / with) Surname (0000) -->
									<xsl:analyze-string select="." regex="([A-Z][^\s]+,\s+[A-Z][^\s]+,\s+[A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+\s+\(\d\d\d\d[a-z]*\)?)[^&#x2013;]">
										<xsl:matching-substring>
											<hit>
												<found>
													<xsl:value-of select="regex-group(1)"/>
													<xsl:value-of select="regex-group(2)"/>
													<xsl:value-of select="regex-group(3)"/>
												</found>
												<preceding-text>
													<xsl:value-of select="substring-before($text,regex-group(1))"/>
												</preceding-text>
												<following-text>
													<xsl:value-of select="substring-after($text,regex-group(3))"/>
												</following-text>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<!--
											-->
											<!-- find Surname, Surname (and / & / with) Surname,? 0000 -->
											<xsl:analyze-string select="." regex="([A-Z][^\s]+,\s+[A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+,?\s+\d\d\d\d[a-z]*)[^&#x2013;]">
												<xsl:matching-substring>
													<hit>
														<found>
															<xsl:value-of select="regex-group(1)"/>
															<xsl:value-of select="regex-group(2)"/>
															<xsl:value-of select="regex-group(3)"/>
														</found>
														<preceding-text>
															<xsl:value-of select="substring-before($text,regex-group(1))"/>
														</preceding-text>
														<following-text>
															<xsl:value-of select="substring-after($text,regex-group(3))"/>
														</following-text>
														<xsl:copy-of select="$location"/>
													</hit>
												</xsl:matching-substring>
												<xsl:non-matching-substring>
													<!--
													-->
													<!-- find Surname, Surname (and / & / with) Surname (0000) -->
													<xsl:analyze-string select="." regex="([A-Z][^\s]+,\s+[A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+\s+\(\d\d\d\d[a-z]*\)?)[^&#x2013;]">
														<xsl:matching-substring>
															<hit>
																<found>
																	<xsl:value-of select="regex-group(1)"/>
																	<xsl:value-of select="regex-group(2)"/>
																	<xsl:value-of select="regex-group(3)"/>
																</found>
																<preceding-text>
																	<xsl:value-of select="substring-before($text,regex-group(1))"/>
																</preceding-text>
																<following-text>
																	<xsl:value-of select="substring-after($text,regex-group(3))"/>
																</following-text>
																<xsl:copy-of select="$location"/>
															</hit>
														</xsl:matching-substring>
														<xsl:non-matching-substring>
															<!--
															-->
															<!-- find Surname (and / & / with) Surname,? 0000 -->
															<xsl:analyze-string select="." regex="([A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+,?\s+\d\d\d\d[a-z]*)[^&#x2013;]">
																<xsl:matching-substring>
																	<hit>
																		<found>
																			<xsl:value-of select="regex-group(1)"/>
																			<xsl:value-of select="regex-group(2)"/>
																			<xsl:value-of select="regex-group(3)"/>
																		</found>
																		<preceding-text>
																			<xsl:value-of select="substring-before($text,regex-group(1))"/>
																		</preceding-text>
																		<following-text>
																			<xsl:value-of select="substring-after($text,regex-group(3))"/>
																		</following-text>
																		<xsl:copy-of select="$location"/>
																	</hit>
																</xsl:matching-substring>
																<xsl:non-matching-substring>
																	<!--
																	-->
																	<!-- find Surname (and / & / with) Surname (0000) -->
																	<xsl:analyze-string select="." regex="([A-Z][^\s]+\s+)(and|&amp;|with)(\s+[A-Z][^\s]+\s+\(\d\d\d\d[a-z]*\)?)[^&#x2013;]">
																		<xsl:matching-substring>
																			<hit>
																				<found>
																					<xsl:value-of select="regex-group(1)"/>
																					<xsl:value-of select="regex-group(2)"/>
																					<xsl:value-of select="regex-group(3)"/>
																				</found>
																				<preceding-text>
																					<xsl:value-of select="substring-before($text,regex-group(1))"/>
																				</preceding-text>
																				<following-text>
																					<xsl:value-of select="substring-after($text,regex-group(3))"/>
																				</following-text>
																				<xsl:copy-of select="$location"/>
																			</hit>
																		</xsl:matching-substring>
																		<xsl:non-matching-substring>
																			<!--
																			-->
																			<!-- find Surname,? 0000 -->
																			<xsl:analyze-string select="." regex="([A-Z][^\s]+,?\s+\d\d\d\d[a-z]*)[^&#x2013;]">
																				<xsl:matching-substring>
																					<hit>
																						<found>
																							<xsl:value-of select="regex-group(1)"/>
																						</found>
																						<preceding-text>
																							<xsl:value-of select="substring-before($text,regex-group(1))"/>
																						</preceding-text>
																						<following-text>
																							<xsl:value-of select="substring-after($text,regex-group(1))"/>
																						</following-text>
																						<xsl:copy-of select="$location"/>
																					</hit>
																				</xsl:matching-substring>
																				<xsl:non-matching-substring>
																					<!--
																					-->
																					<!-- find Surname (0000) -->
																					<xsl:analyze-string select="." regex="([A-Z][^\s]+\s+\(\d\d\d\d[a-z]*\)?)[^&#x2013;]">
																						<xsl:matching-substring>
																							<hit>
																								<found>
																									<xsl:value-of select="regex-group(1)"/>
																								</found>
																								<preceding-text>
																									<xsl:value-of select="substring-before($text,regex-group(1))"/>
																								</preceding-text>
																								<following-text>
																									<xsl:value-of select="substring-after($text,regex-group(1))"/>
																								</following-text>
																								<xsl:copy-of select="$location"/>
																							</hit>
																						</xsl:matching-substring>
																						<xsl:non-matching-substring>
																							<!--
																							-->
																							<!-- find et al. -->
																							<xsl:analyze-string select="." regex="\W(et al\.?)\W">
																								<xsl:matching-substring>
																									<hit>
																										<found>
																											<xsl:value-of select="regex-group(1)"/>
																										</found>
																										<preceding-text>
																											<xsl:value-of select="substring-before($text,regex-group(1))"/>
																										</preceding-text>
																										<following-text>
																											<xsl:value-of select="substring-after($text,regex-group(1))"/>
																										</following-text>
																										<xsl:copy-of select="$location"/>
																									</hit>
																								</xsl:matching-substring>
																							</xsl:analyze-string>
																						</xsl:non-matching-substring>
																					</xsl:analyze-string>
																				</xsl:non-matching-substring>
																			</xsl:analyze-string>
																		</xsl:non-matching-substring>
																	</xsl:analyze-string>
																</xsl:non-matching-substring>
															</xsl:analyze-string>
														</xsl:non-matching-substring>
													</xsl:analyze-string>
												</xsl:non-matching-substring>
											</xsl:analyze-string>
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:otherwise>
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
		<!-- filter hit_list_unfiltered to build hit list -->
		<xsl:variable name="hit_list">
			<xml>
				<xsl:for-each select="$hit_list_unfiltered//hit">
					<xsl:choose>
						<!--
						-->
						<!-- remove hits that include a month -->
						<xsl:when test="matches(./found,'(January|February|March|April|May|June|July|August|September|October|November|December)')"/>
						<xsl:when test="matches(./found,'(Jan\.?|Feb\.?|Mar\.?|Apr\.?|May|Jun\.?|Jul\.?|Aug\.?|Sept?\.?|Oct\.?|Nov\.?|Dec\.?)')"/>
						<!--
						-->
						<!-- remove hits that include 'in' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Ii]n\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'from' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Ff]rom\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'after' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Aa]fter\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'since' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Ss]ince\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'before' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Bb]efore\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'between' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Bb]etween\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'the' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Tt]he\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'this' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Tt]his\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'by' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Bb]y\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include 'copyright' followed by year -->
						<xsl:when test="matches(./found,'(^|\W)([Cc]opyright\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- remove hits that include a word more commonly associated with the name of a publishing house -->
						<xsl:when test="matches(./found,'(^|\W)(Books|Press|Publishing|Publishers|Research|Company|Services|Limited|Centre|Reprints|HarperCollins)(,?\s+\d\d\d\d)($|\W)')"/>
						<!--
						-->
						<!-- otherwise, copy the hit details -->
						<xsl:otherwise>
							<xsl:copy-of select="."/>
						</xsl:otherwise>
					</xsl:choose>
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
						<xsl:element name="tr">
							<xsl:copy-of select="$rule_details"/>
							<xsl:element name="td">
								<xsl:attribute name="class" select="$error_type"/>
								<xsl:text>Found possible untagged reference citation &#x2013; "</xsl:text>
								<xsl:value-of select="./found"/>
								<xsl:text>" (in text: "</xsl:text>
								<xsl:choose>
									<xsl:when test="string-length(./preceding-text) lt 60">
										<xsl:value-of select="./preceding-text"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:text>... </xsl:text>
										<xsl:value-of select="substring(./preceding-text,string-length(./preceding-text)-60,string-length(./preceding-text))"/>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:element name="b">
									<xsl:element name="u">
										<xsl:value-of select="./found"/>
									</xsl:element>
								</xsl:element>
								<xsl:choose>
									<xsl:when test="string-length(./following-text) lt 60">
										<xsl:value-of select="./following-text"/>
									</xsl:when>
									<xsl:otherwise>
										<xsl:value-of select="substring(./following-text,1,60)"/>
										<xsl:text> ...</xsl:text>
									</xsl:otherwise>
								</xsl:choose>
								<xsl:text>" &#x2013; </xsl:text>
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
