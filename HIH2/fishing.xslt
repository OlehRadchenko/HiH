<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes"/>

<xsl:template match="/wedkarstwo">
    <html>
        <head>
            <title>RYBACTWO - Projekt wykonany przez <value-of select="@autor"/></title>
            <link rel="stylesheet" href="fishing.css"/>
        </head>
        <body>
            <header>
                <h1>Wędkarstwo — przegląd połowów i zawodów</h1>
                <div class="small">Wygenerowano z dokumentu XML</div>
            </header>
            <xsl:for-each select="wedkarze">
                <xsl:sort select="@kraj"/>
                <h2>Wędkarze z kraju: <xsl:value-of select="@kraj"/> (Liczba: <xsl:value-of select="@liczba"/>)</h2>
                <xsl:call-template name="wedkarzTemplate"/>
            </xsl:for-each>
            <xsl:apply-templates select="zawody"/>
        </body>
    </html>
</xsl:template>

<xsl:template name="wedkarzTemplate" match="wedkarz">
    <div class="wedkarz">
        <h3>Wędkarz: <xsl:value-of select="@id"/></h3>
        <p>Doświadczenie: <xsl:value-of select="@doswiadczenie"/></p>
        <p>Klub: <xsl:value-of select="@klub"/></p>
        <h4>Połowy:</h4>
        <ul>
            <xsl:for-each select="polow">
                <li><xsl:value-of select="@ryba"/> - Ilość: <xsl:value-of select="@ilosc"/>, Data: <xsl:value-of select="@data"/></li>
            </xsl:for-each>
        </ul>
    </div>

</xsl:template>

</xsl:stylesheet>