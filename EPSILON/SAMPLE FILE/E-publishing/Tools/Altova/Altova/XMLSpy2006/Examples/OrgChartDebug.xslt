<?xml version="1.0" encoding="UTF-8"?>
<!-- edited with XML Spy v5 beta 4 U (http://www.xmlspy.com) by Alex Pilz (pilzindustries) -->
<?xmlspysamplexml OrgChartDebug.xml?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:n1="http://www.xmlspy.com/schemas/orgchart" xmlns:ipo="http://www.altova.com/IPO" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
	<!-- Global Variable Declartions *****************************************-->
	<xsl:variable name="Main_Title" select="string('Employee List')"/>
	<xsl:variable name="Show_Company_Name" select="boolean('true')"/>
	<!-- Root Template ******************************************************-->
	<xsl:template match="n1:OrgChart">
		<html>
			<head>
				<title> Company 1</title>
			</head>
			<table width="60%">
				<tbody>
					<tr>
						<td>
							<h1>
								<xsl:value-of select="$Main_Title"/>
							</h1>
						</td>
						<td align="left">
							<b>
								(sorted by last name)
							</b>
						</td>
					</tr>
				</tbody>
			</table>
			<xsl:for-each select="n1:Office">
				<!-- Local Variable reused -->
				<xsl:variable name="OfficeName" select="n1:Name"/>
				<!-- Display the company name if the varaible is true ********* -->
				<xsl:if test="$Show_Company_Name">
					<h3>
						<xsl:value-of select="$OfficeName"/>
					</h3>
					<xsl:message>
						<xsl:text>Company Named Displayed</xsl:text>
					</xsl:message>
				</xsl:if>
				<table width="60%">
					<tbody>
						<tr bgcolor="#C0C0C0">
							<td>
								<b>First Name</b>
							</td>
							<td>
								<b>Last Name</b>
							</td>
						</tr>
						<!-- Sort and Ouput the employees *********************-->
						<xsl:for-each select="n1:Department/n1:Person">
							<xsl:sort select="n1:Last"/>
							<xsl:variable name="Christian-name" select="n1:First"/>
							<tr>
								<td>
									<xsl:value-of select="$Christian-name"/>
								</td>
								<td>
									<xsl:call-template name="Surname">
										<xsl:with-param name="Family-name" select="n1:Last"/>
									</xsl:call-template>
								</td>
							</tr>
						</xsl:for-each>
					</tbody>
				</table>
				<br/>
				<!-- Local Variable to count the number of employees in the current office -->
				<xsl:variable name="Num_Employees" select="count(n1:Department/n1:Person)"/> 
				The Total Number of employees at, 
				<xsl:value-of select="$OfficeName"/>
				are:
				<b>
					<xsl:value-of select="$Num_Employees"/>
				</b>
				<br/>
			</xsl:for-each>
		</html>
	</xsl:template>
	<!-- Surname Template ********************************************-->
	<xsl:template name="Surname">
		<xsl:param name="Family-name">
			<xsl:value-of select="n1:Last"/>
		</xsl:param>
		<xsl:value-of select="$Family-name"/>
		<br/>
	</xsl:template>
</xsl:stylesheet>
