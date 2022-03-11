<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions">
	<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>
	<!--

	-->
	<xsl:template name="rule_823" match="*">
		<!--
		
		-->
		<!-- SET RULE NUMBER, NAME, AND ERROR TYPE -->
		<xsl:variable name="rule_number">823</xsl:variable>
		<xsl:variable name="rule_name">Check for untagged dates.</xsl:variable>
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
				<!-- select untagged text in mixed-citation -->
				<xsl:for-each select="//mixed-citation/text()">
					<xsl:variable name="text">
						<text>
							<xsl:value-of select="ancestor::ref[1]"/>
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
					<!-- find day month year -->
					<xsl:analyze-string select="." regex="([1-3]?[0-9]\s*)(st|nd|rd|th|)(\s+)(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)(\s+\d\d\d?\d?)">
						<xsl:matching-substring>
							<hit type="day-month-year">
								<found>
									<xsl:value-of select="regex-group(1)"/>
									<xsl:value-of select="regex-group(2)"/>
									<xsl:value-of select="regex-group(3)"/>
									<xsl:value-of select="regex-group(4)"/>
									<xsl:value-of select="regex-group(5)"/>
								</found>
								<xsl:copy-of select="$text"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
						<xsl:non-matching-substring>
							<!--
							-->
							<!-- find year month day -->
							<xsl:analyze-string select="." regex="(\d\d\d?\d?)([,\s]+)(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)(\s+)([1-3]?[0-9]\s*)(st|nd|rd|th|)">
								<xsl:matching-substring>
									<hit type="year-month-day">
										<found>
											<xsl:value-of select="regex-group(1)"/>
											<xsl:value-of select="regex-group(2)"/>
											<xsl:value-of select="regex-group(3)"/>
											<xsl:value-of select="regex-group(4)"/>
											<xsl:value-of select="regex-group(5)"/>
										</found>
										<xsl:copy-of select="$text"/>
										<xsl:copy-of select="$location"/>
									</hit>
								</xsl:matching-substring>
								<xsl:non-matching-substring>
									<!--
									-->
									<!-- find month year -->
									<xsl:analyze-string select="." regex="(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)(\s+\d\d\d?\d?[^a-z])">
										<xsl:matching-substring>
											<hit type="month-year">
												<found>
													<xsl:value-of select="regex-group(1)"/>
													<xsl:value-of select="regex-group(2)"/>
												</found>
												<xsl:copy-of select="$text"/>
												<xsl:copy-of select="$location"/>
											</hit>
										</xsl:matching-substring>
										<xsl:non-matching-substring>
											<!--
											-->
											<!-- find year month -->
											<xsl:analyze-string select="." regex="(\d\d\d\d)([,\s]+)(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)">
												<xsl:matching-substring>
													<hit type="year-month">
														<found>
															<xsl:value-of select="regex-group(1)"/>
															<xsl:value-of select="regex-group(2)"/>
															<xsl:value-of select="regex-group(3)"/>
														</found>
														<xsl:copy-of select="$text"/>
														<xsl:copy-of select="$location"/>
													</hit>
												</xsl:matching-substring>
												<xsl:non-matching-substring>
													<!--
													-->
													<!-- find day month -->
													<xsl:analyze-string select="." regex="([1-3]?[0-9]\s*)(st|nd|rd|th|)(\s+)(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)">
														<xsl:matching-substring>
															<hit type="day-month">
																<found>
																	<xsl:value-of select="regex-group(1)"/>
																	<xsl:value-of select="regex-group(2)"/>
																	<xsl:value-of select="regex-group(3)"/>
																	<xsl:value-of select="regex-group(4)"/>
																</found>
																<xsl:copy-of select="$text"/>
																<xsl:copy-of select="$location"/>
															</hit>
														</xsl:matching-substring>
														<xsl:non-matching-substring>
															<!--
															-->
															<!-- find month day -->
															<xsl:analyze-string select="." regex="(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)([,\s]+)([1-3]?[0-9]\s*)(st|nd|rd|th|)">
																<xsl:matching-substring>
																	<hit type="month-day">
																		<found>
																			<xsl:value-of select="regex-group(1)"/>
																			<xsl:value-of select="regex-group(2)"/>
																			<xsl:value-of select="regex-group(3)"/>
																			<xsl:value-of select="regex-group(4)"/>
																		</found>
																		<xsl:copy-of select="$text"/>
																		<xsl:copy-of select="$location"/>
																	</hit>
																</xsl:matching-substring>
																<xsl:non-matching-substring>
																	<!--
																	-->
																	<!-- find season year -->
																	<xsl:analyze-string select="." regex="([Ss]pring|[Ss]ummer|[Aa]utumn|[Ff]all|[Ww]inter)(,?\s+\d\d\d?\d?[^a-z])">
																		<xsl:matching-substring>
																			<hit type="season-year">
																				<found>
																					<xsl:value-of select="regex-group(1)"/>
																					<xsl:value-of select="regex-group(2)"/>
																				</found>
																				<xsl:copy-of select="$text"/>
																				<xsl:copy-of select="$location"/>
																			</hit>
																		</xsl:matching-substring>
																		<xsl:non-matching-substring>
																			<!--
																			-->
																			<!-- find year season -->
																			<xsl:analyze-string select="." regex="(\d\d\d?\d?)([,\s]+)([Ss]pring|[Ss]ummer|[Aa]utumn|[Ff]all|[Ww]inter)">
																				<xsl:matching-substring>
																					<hit type="year-season">
																						<found>
																							<xsl:value-of select="regex-group(1)"/>
																							<xsl:value-of select="regex-group(2)"/>
																							<xsl:value-of select="regex-group(3)"/>
																						</found>
																						<xsl:copy-of select="$text"/>
																						<xsl:copy-of select="$location"/>
																					</hit>
																				</xsl:matching-substring>
																				<xsl:non-matching-substring>
																					<!--
																					-->
																					<!-- find month -->
																					<xsl:analyze-string select="." regex="(January|February|March|April|May|June|July|August|September|October|November|December|Jan\.|Feb\.|Mar\.|Apr\.|Jun\.|Jul\.|Aug\.|Sept?\.|Oct\.|Nov\.|Dec\.)">
																						<xsl:matching-substring>
																							<hit type="month">
																								<found>
																									<xsl:value-of select="regex-group(1)"/>
																								</found>
																								<xsl:copy-of select="$text"/>
																								<xsl:copy-of select="$location"/>
																							</hit>
																						</xsl:matching-substring>
																						<xsl:non-matching-substring>
																							<!--
																							-->
																							<!-- find numerical date format -->
																							<xsl:analyze-string select="." regex="\D(\d\d?)(/|\.)(\d\d?)(/|\.)(\d\d\d?\d?)\D">
																								<xsl:matching-substring>
																									<hit type="numerical">
																										<found>
																											<xsl:value-of select="regex-group(1)"/>
																											<xsl:value-of select="regex-group(2)"/>
																											<xsl:value-of select="regex-group(3)"/>
																											<xsl:value-of select="regex-group(4)"/>
																											<xsl:value-of select="regex-group(5)"/>
																										</found>
																										<xsl:copy-of select="$text"/>
																										<xsl:copy-of select="$location"/>
																									</hit>
																								</xsl:matching-substring>
																								<xsl:non-matching-substring>
																									<!--
																									-->
																									<!-- find year -->
																									<xsl:analyze-string select="." regex="\D([1-2]\d\d\d)\D">
																										<xsl:matching-substring>
																											<hit type="year">
																												<found>
																													<xsl:value-of select="regex-group(1)"/>
																												</found>
																												<xsl:copy-of select="$text"/>
																												<xsl:copy-of select="$location"/>
																											</hit>
																										</xsl:matching-substring>
																										<xsl:non-matching-substring>
																											<!--
																											-->
																											<!-- find season -->
																											<xsl:analyze-string select="." regex="\W([Ss]pring|[Ss]ummer|[Aa]utumn|[Ff]all|[Ww]inter)\W">
																												<xsl:matching-substring>
																													<hit type="season">
																														<found>
																															<xsl:value-of select="regex-group(1)"/>
																														</found>
																														<xsl:copy-of select="$text"/>
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
										</xsl:non-matching-substring>
									</xsl:analyze-string>
								</xsl:non-matching-substring>
							</xsl:analyze-string>
						</xsl:non-matching-substring>
					</xsl:analyze-string>
					<!--
					-->
				</xsl:for-each>
				<!--
				-->
				<!-- find day text around month element -->
				<xsl:for-each select="//mixed-citation/month">
					<!--
					-->
					<!-- set variables -->
					<xsl:variable name="month" select="."/>
					<xsl:variable name="preceding-text">
						<xsl:for-each select="preceding-sibling::text()">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="following-text">
						<xsl:for-each select="following-sibling::text()">
							<xsl:value-of select="."/>
							<xsl:text> </xsl:text>
						</xsl:for-each>
					</xsl:variable>
					<xsl:variable name="text">
						<text>
							<xsl:value-of select="ancestor::ref[1]"/>
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
					<!-- test if preceding text ends in day -->
					<xsl:analyze-string select="$preceding-text" regex="([1-3]?[0-9]\s*)(st|nd|rd|th|)\s*$">
						<xsl:matching-substring>
							<hit type="day">
								<found>
									<xsl:value-of select="regex-group(1)"/>
									<xsl:value-of select="regex-group(2)"/>
								</found>
								<month>
									<xsl:value-of select="$month"/>
								</month>
								<xsl:copy-of select="$text"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
					<!--
					-->
					<!-- test if following text starts with day -->
					<xsl:analyze-string select="$following-text" regex="^\s*([1-3]?[0-9]\s*)(st|nd|rd|th|)">
						<xsl:matching-substring>
							<hit type="day">
								<found>
									<xsl:value-of select="regex-group(1)"/>
									<xsl:value-of select="regex-group(2)"/>
								</found>
								<month>
									<xsl:value-of select="$month"/>
								</month>
								<xsl:copy-of select="$text"/>
								<xsl:copy-of select="$location"/>
							</hit>
						</xsl:matching-substring>
					</xsl:analyze-string>
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
								<xsl:text>Found possible untagged </xsl:text>
								<xsl:choose>
									<xsl:when test="./@type = 'day-month-year'">
										<xsl:text>day, month, and year</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'year-month-day'">
										<xsl:text>year, month, and day</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'month-year'">
										<xsl:text>month and year</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'year-month'">
										<xsl:text>year and month</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'day-month'">
										<xsl:text>day and month</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'month-day'">
										<xsl:text>month and day</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'season-year'">
										<xsl:text>season and year</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'year-season'">
										<xsl:text>year and season</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'month'">
										<xsl:text>month</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'year'">
										<xsl:text>year</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'season'">
										<xsl:text>season</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'numerical'">
										<xsl:text>numerical date</xsl:text>
									</xsl:when>
									<xsl:when test="./@type = 'day'">
										<xsl:text>day</xsl:text>
									</xsl:when>
								</xsl:choose>
								<xsl:text> ("</xsl:text>
								<xsl:value-of select="./found"/>
								<xsl:text>") in reference "</xsl:text>
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
