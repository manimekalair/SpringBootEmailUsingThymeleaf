<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:ipo="http://www.altova.com/IPO" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:n1="http://www.xmlspy.com/schemas/orgchart">
    <xsl:output version="1.0" encoding="UTF-8" indent="no" omit-xml-declaration="no" media-type="text/html" />
    <xsl:template match="/">
        <html>
            <head>
                <title />
            </head>
            <body>
                <xsl:for-each select="n1:OrgChart">
                    <xsl:for-each select="n1:CompanyLogo">
                        <div style="border-bottom-color:#0588BA; border-bottom-style:solid; border-bottom-width:medium; border-width:4pt; padding-bottom:10px; padding-left:10px; ">
                            <xsl:for-each select="@href">
                                <a>
                                    <xsl:attribute name="href"><xsl:text disable-output-escaping="yes">http://www.nanonull.com/</xsl:text></xsl:attribute>
                                    <img border="0">
                                        <xsl:attribute name="src"><xsl:value-of select="." /></xsl:attribute>
                                    </img>
                                </a>
                            </xsl:for-each>
                        </div>
                    </xsl:for-each>
                    <br />
                    <xsl:for-each select="n1:Name">
                        <span style="color:#0588BA; font-family:Arial; font-size:20pt; font-weight:bold; ">
                            <xsl:apply-templates />
                        </span>
                    </xsl:for-each>
                    <br />
                    <br />
                    <xsl:for-each select="n1:Office">
                        <br />
                        <div style="border-top-color:#0588ba; border-top-style:solid; border-top-width:2pt; ">
                            <br />
                            <xsl:for-each select="n1:Name">
                                <span style="color:#707070; font-family:Arial; font-size:15pt; font-weight:bold; ">
                                    <xsl:apply-templates />
                                </span>
                            </xsl:for-each>
                            <br />
                            <br />
                            <span style="color:#808080; font-family:Arial; font-size:smaller; font-weight:bold; ">Location: </span>
                            <xsl:choose>
                                <xsl:when test="not(n1:Address or  n1:Address_EU)">
                                    <xsl:for-each select="n1:Location">
                                        <select size="0">
                                            <option value="US">
                                                <xsl:if test="string(.)='US'">
                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                </xsl:if>US</option>
                                            <option value="EU">
                                                <xsl:if test="string(.)='EU'">
                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                </xsl:if>EU</option>
                                        </select>
                                    </xsl:for-each>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:for-each select="n1:Location">
                                        <span style="color:#808080; font-weight:bold; ">
                                            <xsl:apply-templates />
                                        </span>
                                    </xsl:for-each>
                                </xsl:otherwise>
                            </xsl:choose>
                        </div>
                        <table border="1" cellspacing="0" width="100%">
                            <tbody>
                                <tr>
                                    <td valign="top" width="60%">
                                        <xsl:choose>
                                            <xsl:when test="n1:Location =&quot;US&quot;">
                                                <xsl:for-each select="n1:Address">
                                                    <table border="0" cellspacing="4px" width="100%">
                                                        <tbody>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">Street: </span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:street">
                                                                        <xsl:apply-templates />
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">City:</span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:city">
                                                                        <xsl:apply-templates />
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">State &amp; Zip:</span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:state">
                                                                        <select size="0">
                                                                            <option value="AK">
                                                                                <xsl:if test="string(.)='AK'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>AK</option>
                                                                            <option value="AL">
                                                                                <xsl:if test="string(.)='AL'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>AL</option>
                                                                            <option value="AR">
                                                                                <xsl:if test="string(.)='AR'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>AR</option>
                                                                            <option value="AZ">
                                                                                <xsl:if test="string(.)='AZ'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>AZ</option>
                                                                            <option value="CA">
                                                                                <xsl:if test="string(.)='CA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>CA</option>
                                                                            <option value="CO">
                                                                                <xsl:if test="string(.)='CO'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>CO</option>
                                                                            <option value="CT">
                                                                                <xsl:if test="string(.)='CT'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>CT</option>
                                                                            <option value="DC">
                                                                                <xsl:if test="string(.)='DC'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>DC</option>
                                                                            <option value="DE">
                                                                                <xsl:if test="string(.)='DE'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>DE</option>
                                                                            <option value="FL">
                                                                                <xsl:if test="string(.)='FL'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>FL</option>
                                                                            <option value="GA">
                                                                                <xsl:if test="string(.)='GA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>GA</option>
                                                                            <option value="GU">
                                                                                <xsl:if test="string(.)='GU'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>GU</option>
                                                                            <option value="HI">
                                                                                <xsl:if test="string(.)='HI'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>HI</option>
                                                                            <option value="IA">
                                                                                <xsl:if test="string(.)='IA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>IA</option>
                                                                            <option value="ID">
                                                                                <xsl:if test="string(.)='ID'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>ID</option>
                                                                            <option value="IL">
                                                                                <xsl:if test="string(.)='IL'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>IL</option>
                                                                            <option value="IN">
                                                                                <xsl:if test="string(.)='IN'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>IN</option>
                                                                            <option value="KS">
                                                                                <xsl:if test="string(.)='KS'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>KS</option>
                                                                            <option value="KY">
                                                                                <xsl:if test="string(.)='KY'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>KY</option>
                                                                            <option value="LA">
                                                                                <xsl:if test="string(.)='LA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>LA</option>
                                                                            <option value="MA">
                                                                                <xsl:if test="string(.)='MA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MA</option>
                                                                            <option value="MD">
                                                                                <xsl:if test="string(.)='MD'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MD</option>
                                                                            <option value="ME">
                                                                                <xsl:if test="string(.)='ME'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>ME</option>
                                                                            <option value="MI">
                                                                                <xsl:if test="string(.)='MI'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MI</option>
                                                                            <option value="MN">
                                                                                <xsl:if test="string(.)='MN'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MN</option>
                                                                            <option value="MO">
                                                                                <xsl:if test="string(.)='MO'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MO</option>
                                                                            <option value="MS">
                                                                                <xsl:if test="string(.)='MS'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MS</option>
                                                                            <option value="MT">
                                                                                <xsl:if test="string(.)='MT'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>MT</option>
                                                                            <option value="NC">
                                                                                <xsl:if test="string(.)='NC'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NC</option>
                                                                            <option value="ND">
                                                                                <xsl:if test="string(.)='ND'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>ND</option>
                                                                            <option value="NE">
                                                                                <xsl:if test="string(.)='NE'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NE</option>
                                                                            <option value="NH">
                                                                                <xsl:if test="string(.)='NH'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NH</option>
                                                                            <option value="NJ">
                                                                                <xsl:if test="string(.)='NJ'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NJ</option>
                                                                            <option value="NM">
                                                                                <xsl:if test="string(.)='NM'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NM</option>
                                                                            <option value="NV">
                                                                                <xsl:if test="string(.)='NV'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NV</option>
                                                                            <option value="NY">
                                                                                <xsl:if test="string(.)='NY'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>NY</option>
                                                                            <option value="OH">
                                                                                <xsl:if test="string(.)='OH'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>OH</option>
                                                                            <option value="OK">
                                                                                <xsl:if test="string(.)='OK'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>OK</option>
                                                                            <option value="OR">
                                                                                <xsl:if test="string(.)='OR'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>OR</option>
                                                                            <option value="PA">
                                                                                <xsl:if test="string(.)='PA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>PA</option>
                                                                            <option value="PR">
                                                                                <xsl:if test="string(.)='PR'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>PR</option>
                                                                            <option value="RI">
                                                                                <xsl:if test="string(.)='RI'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>RI</option>
                                                                            <option value="SC">
                                                                                <xsl:if test="string(.)='SC'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>SC</option>
                                                                            <option value="SD">
                                                                                <xsl:if test="string(.)='SD'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>SD</option>
                                                                            <option value="TN">
                                                                                <xsl:if test="string(.)='TN'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>TN</option>
                                                                            <option value="TX">
                                                                                <xsl:if test="string(.)='TX'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>TX</option>
                                                                            <option value="UT">
                                                                                <xsl:if test="string(.)='UT'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>UT</option>
                                                                            <option value="VA">
                                                                                <xsl:if test="string(.)='VA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>VA</option>
                                                                            <option value="VI">
                                                                                <xsl:if test="string(.)='VI'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>VI</option>
                                                                            <option value="VT">
                                                                                <xsl:if test="string(.)='VT'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>VT</option>
                                                                            <option value="WA">
                                                                                <xsl:if test="string(.)='WA'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>WA</option>
                                                                            <option value="WI">
                                                                                <xsl:if test="string(.)='WI'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>WI</option>
                                                                            <option value="WV">
                                                                                <xsl:if test="string(.)='WV'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>WV</option>
                                                                            <option value="WY">
                                                                                <xsl:if test="string(.)='WY'">
                                                                                    <xsl:attribute name="selected">1</xsl:attribute>
                                                                                </xsl:if>WY</option>
                                                                        </select>
                                                                    </xsl:for-each>&#160;<xsl:for-each select="ipo:zip">
                                                                        <input value="">
                                                                            <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
                                                                        </input>
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </xsl:for-each>
                                            </xsl:when>
                                            <xsl:when test="n1:Location =&quot;EU&quot;">
                                                <xsl:for-each select="n1:Address_EU">
                                                    <table border="0" cellspacing="4px" width="100%">
                                                        <tbody>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">Street:</span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:street">
                                                                        <input value="">
                                                                            <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
                                                                        </input>
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">City:</span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:city">
                                                                        <input value="">
                                                                            <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
                                                                        </input>
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                            <tr>
                                                                <td width="30%">
                                                                    <span style="font-weight:bold; ">Post Code:</span>
                                                                </td>
                                                                <td width="70%">
                                                                    <xsl:for-each select="ipo:postcode">
                                                                        <input value="">
                                                                            <xsl:attribute name="value"><xsl:value-of select="." /></xsl:attribute>
                                                                        </input>
                                                                    </xsl:for-each>
                                                                </td>
                                                            </tr>
                                                        </tbody>
                                                    </table>
                                                </xsl:for-each>
                                            </xsl:when>
                                        </xsl:choose>
                                    </td>
                                    <td valign="top" width="40%">
                                        <table border="0" cellspacing="4" width="100%">
                                            <tbody>
                                                <tr>
                                                    <td width="25%">
                                                        <span style="font-weight:bold; ">Phone:</span>
                                                    </td>
                                                    <td width="75%">
                                                        <xsl:for-each select="n1:Phone">
                                                            <xsl:apply-templates />
                                                        </xsl:for-each>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="25%">
                                                        <span style="font-weight:bold; ">Fax:</span>
                                                    </td>
                                                    <td width="75%">
                                                        <xsl:for-each select="n1:Fax">
                                                            <xsl:apply-templates />
                                                        </xsl:for-each>
                                                    </td>
                                                </tr>
                                                <tr>
                                                    <td width="25%">
                                                        <span style="font-weight:bold; ">E-mail:</span>
                                                    </td>
                                                    <td width="75%">
                                                        <xsl:for-each select="n1:EMail">
                                                            <a>
                                                                <xsl:attribute name="href"><xsl:text disable-output-escaping="yes">mailto:</xsl:text><xsl:value-of select="." /></xsl:attribute>
                                                                <xsl:apply-templates />
                                                            </a>
                                                        </xsl:for-each>
                                                    </td>
                                                </tr>
                                            </tbody>
                                        </table>
                                    </td>
                                </tr>
                            </tbody>
                        </table>
                        <br />
                        <xsl:choose>
                            <xsl:when test="n1:Address">
                                <xsl:for-each select="n1:Address">
                                    <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">
                                        <xsl:for-each select="ipo:city">
                                            <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; text-decoration:underline; ">
                                                <xsl:apply-templates />
                                            </span>
                                        </xsl:for-each>
                                    </span>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:when test="n1:Address_EU">
                                <xsl:for-each select="n1:Address_EU">
                                    <xsl:for-each select="ipo:city">
                                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; text-decoration:underline; ">
                                            <xsl:apply-templates />
                                        </span>
                                    </xsl:for-each>
                                </xsl:for-each>
                            </xsl:when>
                        </xsl:choose>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; text-decoration:underline; "> Office Summary:</span>&#160; <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">
                            <xsl:value-of select="count(n1:Department)" />
                        </span>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; "> department</span>
                        <xsl:if test="count(n1:Department) != 1">
                            <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">s</span>
                        </xsl:if>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">, </span>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">
                            <xsl:value-of select="count(n1:Department/n1:Person)" />
                        </span>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; "> employee</span>
                        <xsl:if test="count(n1:Department/n1:Person) != 1">
                            <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">s</span>
                        </xsl:if>
                        <span style="color:#004080; font-family:Arial; font-size:10pt; font-weight:bold; ">.</span>
                        <xsl:for-each select="n1:Desc">
                            <xsl:for-each select="n1:para">
                                <p>
                                    <xsl:apply-templates />
                                </p>
                            </xsl:for-each>
                        </xsl:for-each>
                        <xsl:for-each select="n1:Department">
                            <br />
                            <xsl:for-each select="n1:Name">
                                <span style="color:#D39658; font-family:Arial; font-weight:bold; ">
                                    <xsl:apply-templates />
                                </span>
                            </xsl:for-each>&#160; <span style="color:#D39658; "></span>
                            <span style="color:#D39658; font-family:Arial; font-weight:bold; ">( </span>
                            <span style="color:#D39658; font-family:Arial; font-weight:bold; ">
                                <xsl:value-of select="count(n1:Person)" />
                            </span>
                            <span style="color:#D39658; font-family:Arial; font-weight:bold; "> )</span>
                            <br />
                            <table border="1" cellpadding="3" cellspacing="0" width="100%">
                                <thead>
                                    <tr bgcolor="#D2C8AE">
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="10%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">First</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="12%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Last</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="16%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Title</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="5%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Ext</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="23%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">EMail</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" rowspan="2" width="10%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Shares</span>
                                        </td>
                                        <td align="center" colspan="3" width="8%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Leave</span>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td align="center" bgcolor="#D2C8AE" width="8%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Total</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" width="8%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Used</span>
                                        </td>
                                        <td align="center" bgcolor="#D2C8AE" width="8%">
                                            <span style="color:#606060; font-family:Arial; font-weight:bold; ">Left</span>
                                        </td>
                                    </tr>
                                </thead>
                                <tfoot>
                                    <tr bgcolor="#F2F0E6">
                                        <td align="left" colspan="5" valign="top" width="23%">
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">Employees:&#160; </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="count(  n1:Person  )" />
                                            </span>
                                            <span style="font-size:8pt; ">&#160;</span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">(</span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="round ((count(  n1:Person  ) ) div ( count( ../n1:Department/ n1:Person  ) ) * 100)" />
                                            </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">% of Office, </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="round ((count(  n1:Person  ) ) div ( count( ../../n1:Office/n1:Department/ n1:Person  ) ) * 100)" />
                                            </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">% of Company)</span>
                                        </td>
                                        <td align="left" colspan="4" width="10%">
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">Shares: </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="sum(  n1:Person/n1:Shares  )" />
                                            </span>
                                            <span style="font-size:8pt; ">&#160;</span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">(</span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="round((sum(  n1:Person/n1:Shares  ) ) div (sum(../n1:Department/ n1:Person/n1:Shares ) ) * 100)" />
                                            </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">% of Office, </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                <xsl:value-of select="round((sum(  n1:Person/n1:Shares  ) ) div (sum(../../n1:Office/n1:Department/ n1:Person/n1:Shares  )) * 100)" />
                                            </span>
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">% of Company)</span>
                                        </td>
                                    </tr>
                                    <tr bgcolor="#F2F0E6">
                                        <td align="left" colspan="9" width="23%">
                                            <span style="color:#004080; font-family:Arial; font-size:8pt; font-weight:bold; ">Non-Shareholders: </span>
                                            <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">&#160;</span>
                                            <xsl:for-each select="n1:Person">
                                                <xsl:if test="n1:Shares &lt;= 0 or not (n1:Shares)">
                                                    <xsl:for-each select="n1:First">
                                                        <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                            <xsl:apply-templates />
                                                        </span>
                                                    </xsl:for-each>
                                                    <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">&#160;</span>
                                                    <xsl:for-each select="n1:Last">
                                                        <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">
                                                            <xsl:apply-templates />
                                                        </span>
                                                    </xsl:for-each>
                                                    <xsl:if test="following-sibling::n1:Person[n1:Shares&lt;=0 or not(n1:Shares)]">
                                                        <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">, </span>
                                                    </xsl:if>
                                                </xsl:if>
                                            </xsl:for-each>
                                            <xsl:if test="count(  n1:Person  ) = count(  n1:Person [n1:Shares&gt;0] )">
                                                <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">None</span>
                                            </xsl:if>
                                            <span style="color:#004040; font-family:Arial; font-size:8pt; font-weight:bold; ">.</span>
                                        </td>
                                    </tr>
                                </tfoot>
                                <tbody>
                                    <xsl:for-each select="n1:Person">
                                        <tr>
                                            <td width="10%">
                                                <xsl:for-each select="n1:First">
                                                    <xsl:choose>
                                                        <xsl:when test="../n1:Shares &gt; 0">
                                                            <span style="font-size:10pt; font-weight:bold; ">
                                                                <xsl:apply-templates />
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <span style="font-size:10pt; ">
                                                                <xsl:apply-templates />
                                                            </span>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            </td>
                                            <td width="12%">
                                                <xsl:for-each select="n1:Last">
                                                    <xsl:choose>
                                                        <xsl:when test="../n1:Shares &gt; 0">
                                                            <span style="font-size:10pt; font-weight:bold; ">
                                                                <xsl:apply-templates />
                                                            </span>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <span style="font-size:10pt; ">
                                                                <xsl:apply-templates />
                                                            </span>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </xsl:for-each>
                                            </td>
                                            <td width="16%">
                                                <xsl:for-each select="n1:Title">
                                                    <span style="font-size:10pt; ">
                                                        <xsl:apply-templates />
                                                    </span>
                                                </xsl:for-each>
                                            </td>
                                            <td align="center" width="5%">
                                                <xsl:for-each select="n1:PhoneExt">
                                                    <span style="font-size:10pt; ">
                                                        <xsl:apply-templates />
                                                    </span>
                                                </xsl:for-each>
                                            </td>
                                            <td width="23%">
                                                <xsl:for-each select="n1:EMail">
                                                    <a>
                                                        <xsl:attribute name="href"><xsl:text disable-output-escaping="yes">mailto:</xsl:text><xsl:value-of select="." /></xsl:attribute>
                                                        <span style="font-size:10pt; ">
                                                            <xsl:apply-templates />
                                                        </span>
                                                    </a>
                                                </xsl:for-each>
                                            </td>
                                            <td align="center" width="10%">
                                                <xsl:for-each select="n1:Shares">
                                                    <span style="font-size:10pt; ">
                                                        <xsl:apply-templates />
                                                    </span>
                                                </xsl:for-each>
                                            </td>
                                            <td align="center" width="8%">
                                                <xsl:for-each select="n1:LeaveTotal">
                                                    <span style="font-size:10pt; ">
                                                        <xsl:apply-templates />
                                                    </span>
                                                </xsl:for-each>
                                            </td>
                                            <td align="center" width="8%">
                                                <xsl:for-each select="n1:LeaveUsed">
                                                    <span style="font-size:10pt; ">
                                                        <xsl:apply-templates />
                                                    </span>
                                                </xsl:for-each>
                                            </td>
                                            <td align="center" width="8%">
                                                <span style="font-size:10pt; ">
                                                    <xsl:value-of select="n1:LeaveTotal - n1:LeaveUsed" />
                                                </span>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                            <br />
                        </xsl:for-each>
                    </xsl:for-each>
                    <br />
                </xsl:for-each>
            </body>
        </html>
    </xsl:template>
    <xsl:template match="n1:bold">
        <span style="font-weight:bold; ">
            <xsl:apply-templates />
        </span>
    </xsl:template>
    <xsl:template match="n1:italic">
        <span style="font-style:italic; ">
            <xsl:apply-templates />
        </span>
    </xsl:template>
</xsl:stylesheet>
