<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- ===================================================================
      fishing.xsl
      Transformacja XML -> HTML (styl "magazynowy"). Wersja XSLT 1.0.
      =================================================================== -->

  <!-- globalny parametr (możesz zmienić, np. maks liczba zdjęć do pokazania) -->
  <xsl:output method="html" indent="yes"/>
  <xsl:param name="max-images" select="5"/>
  <xsl:template match="/wedkarstwo">
    <html>
      <head>
        <meta charset="utf-8"/>
        <title>Wędkarstwo - przegląd połowów</title>
        <link rel="stylesheet" href="fishing.css"/>
      </head>
      <body>
        <header>
          <h1>Wędkarstwo — przegląd połowów i zawodów</h1>
          <div class="small">Wygenerowano z dokumentu XML</div>
        </header>

        <!-- użyjemy named template do sumarycznego nagłówka krajów -->
        <xsl:call-template name="country-summary"/>
            <!--Lista krajów (pętla + sortowanie)
            - wymaganie: pętla + sort w połączeniu
            - sortujemy wedkarze według @kraj rosnąco-->
        <xsl:for-each select="wedkarze">
          <xsl:sort select="@kraj" data-type="text" order="ascending"/>
          <div class="country" id="{concat('kraj-', normalize-space(@kraj))}">
            <h2>
              <xsl:value-of select="@kraj"/>
              <span class="small"> — liczba wpisów: <xsl:value-of select="@liczba"/></span>
            </h2>

            <!-- zmienna z węzłami wędkarzy w tym bloku (przykład zmiennej złożonej) -->
            <xsl:variable name="local-anglers" select="wedkarz"/>

            <!-- Demonstracja predykatu: wybierz wędkarza o id='w1' (predykat #1) -->
            <xsl:choose>
              <xsl:when test="$local-anglers[@id='w1']">
                <div class="small">Zwrócono uwagę: wędkarz o id 'w1' istnieje w tym kraju.</div>
              </xsl:when>
              <xsl:otherwise>
                <div class="small">Brak szczególnego wędkarza 'w1' w tym kraju.</div>
              </xsl:otherwise>
            </xsl:choose>

            <!-- wypisz wszystkie karty wędkarzy (pętla), numerujemy je (xsl:number użyte 1 raz) -->
            <xsl:for-each select="$local-anglers">
              <!-- sortujemy wewnętrznie według doswiadczenie (przykład sort + predykat) -->
              <xsl:sort select="@doswiadczenie" data-type="text" order="descending"/>
              <div class="angler-card">
                <!-- numeracja pozycji: inny parametr number (numeracja poziomu lokalnego) -->
                <div style="width:72px; text-align:center;">
                  <div class="small">#<xsl:number level="single" count="wedkarz"/></div>
                  <!-- image placeholder (można pobrać avatar z localStorage w JS, tu statycznie) -->
                  <img class="avatar" src="{concat('images/avatar-', substring-after(@id, 'w'), '.png')}" alt="avatar"/>
                </div>

                <div style="flex:1;">
                  <div style="display:flex; justify-content:space-between; align-items:baseline;">
                    <div>
                      <strong><xsl:value-of select="dane/imie"/> <xsl:value-of select="dane/nazwisko"/></strong>
                      <div class="meta">Klub: <xsl:value-of select="@klub"/> — doświadczenie: <xsl:value-of select="@doswiadczenie"/></div>
                    </div>
                    <div class="small">wiek: <xsl:value-of select="dane/wiek"/></div>
                  </div>

                  <!-- wywołanie named template pokazującego sprzęt -->
                  <xsl:call-template name="show-sprzet">
                    <xsl:with-param name="spr" select="sprzet"/>
                  </xsl:call-template>

                  <!-- pokaż połowy -->
                  <xsl:if test="polowy">
                    <div class="small">Połowy:</div>
                    <xsl:for-each select="polowy/polow">
                      <!-- sort: posortuj połowy po dacie (predykat użyty z funkcją substring) -->
                      <xsl:sort select="@data" data-type="text" order="ascending"/>
                      <div class="polow">
                        <h4>
                          <xsl:value-of select="concat(gatunek, ' — ', @miejsce)"/>
                          <span class="small"> (data: <xsl:value-of select="@data"/>)</span>
                        </h4>

                        <!-- VAR prosta: tytuł skrócony -->
                        <xsl:variable name="shortTitle" select="substring-before(normalize-space(opisPolowu),'.')"/>
                        <div class="summary">
                          <xsl:choose>
                            <xsl:when test="string-length($shortTitle) &gt; 0">
                              <xsl:value-of select="$shortTitle"/>...
                            </xsl:when>
                            <xsl:otherwise>
                              <xsl:value-of select="normalize-space(opisPolowu)"/>
                            </xsl:otherwise>
                          </xsl:choose>
                        </div>

                        <!-- format-number: pokaż wagę z formatowaniem (pierwsze format-number) -->
                        <xsl:if test="wagaNajwiekszejRyby and normalize-space(wagaNajwiekszejRyby) != 'BRAK DANYCH'">
                          <div class="small">Waga (sformatowana): 
                            <xsl:value-of select="format-number(number(wagaNajwiekszejRyby), '#,##0.0')"/>
                            <xsl:text> </xsl:text>
                            <xsl:value-of select="wagaNajwiekszejRyby/@jednostka"/>
                          </div>
                        </xsl:if>

                        <!-- pokaz zdjęcia: wykorzystanie atrybutu src z XML (wymóg: zdjęcia pobrane z XML) -->
                        <div class="gallery">
                          <xsl:for-each select="zdjecie[position() &lt;= $max-images]">
                            <img src="{@src}" alt="{@opis}"/>
                          </xsl:for-each>
                        </div>

                        <!-- pokaz lowisko (XPath z predykatem: wybierz to lowisko które ma element <rzeka> lub <jezioro> - predykat 2) -->
                        <div class="small">
                          <xsl:choose>
                            <xsl:when test="lowisko/rzeka">
                              Lowisko: <xsl:value-of select="lowisko/rzeka"/>
                              <xsl:text> (</xsl:text><xsl:value-of select="lowisko/rzeka/@link"/><xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:when test="lowisko/jezioro">
                              Lowisko: <xsl:value-of select="lowisko/jezioro"/>
                              <xsl:text> (</xsl:text><xsl:value-of select="lowisko/jezioro/@link"/><xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:when test="lowisko/morze">
                              Lowisko: <xsl:value-of select="lowisko/morze"/>
                              <xsl:text> (</xsl:text><xsl:value-of select="lowisko/morze/@link"/><xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>Lowisko: nieznane</xsl:otherwise>
                          </xsl:choose>
                        </div>

                      </div> <!-- .polow -->
                    </xsl:for-each>
                  </xsl:if>
                </div>
              </div> <!-- .angler-card -->
            </xsl:for-each>

          </div> <!-- .country -->
        </xsl:for-each>

        <!-- dodatkowa sekcja: zawody (oddzielny template będzie dopasowany do elementu 'zawody') -->
        <xsl:apply-templates select="zawody"/>

      </body>
    </html>
  </xsl:template>
    <!-- 
         Named template: podsumowanie krajów
          -->
  <xsl:template name="country-summary">
    <div class="small">Lista wszystkich krajów w dokumencie:
      <xsl:for-each select="wedkarze">
        <xsl:sort select="@kraj"/>
        <a class="small links" href="#{concat('kraj-', normalize-space(@kraj))}">
          <xsl:value-of select="@kraj"/>
        </a>
        <xsl:if test="position() != last()">, </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="show-sprzet">
    <xsl:param name="spr"/>
    <xsl:apply-templates select="$spr"/>
  </xsl:template>

  <!-- 
       Template dla sprzet (szablon dopasowany do elementu 'sprzet')
        -->
  <xsl:template match="sprzet">
    <div class="meta">
      <strong>Sprzęt:</strong>
      <xsl:apply-templates select="wedka | kolowrotek | zylka"/>
    </div>
  </xsl:template>

  <xsl:template match="wedka">
    <div class="small">Wędka: <xsl:value-of select="@typ"/> (<xsl:value-of select="@marka"/>, <xsl:value-of select="@dlugosc"/>)</div>
  </xsl:template>
  <xsl:template match="kolowrotek">
    <div class="small">Kołowrotek: <xsl:value-of select="@marka"/> <xsl:value-of select="@model"/></div>
  </xsl:template>
  <xsl:template match="zylka">
    <div class="small">Żyłka: <xsl:value-of select="@grubosc"/> (wytrzymałość: <xsl:value-of select="@wytrzymalosc"/>)</div>
  </xsl:template>

  <!-- 
       Template dopasowany do elementu 'zawody' (szablon elementowy)
        -->
  <xsl:template match="zawody">
    <div class="country" style="background:#fffbee;">
      <h2>Zawody — <xsl:value-of select="@rok"/> (<xsl:value-of select="@kraj"/>)</h2>

      <xsl:apply-templates select="organizator"/>
      <xsl:if test="uczestnicy">
        <div class="top-list">
          <strong>Uczestnicy:</strong>
          <xsl:for-each select="uczestnicy/uczestnik">
            <xsl:sort select="@doswiadczenie" order="descending"/>
            <div class="small">
              <xsl:number level="any" count="uczestnik"/>. <xsl:value-of select="imie"/> <xsl:value-of select="nazwisko"/> (<xsl:value-of select="@klub"/>)
            </div>
          </xsl:for-each>
        </div>
      </xsl:if>

      <!-- wyniki: pętla + sort (sortujemy po punkty malejąco) -->
      <xsl:if test="wyniki/pozycja">
        <div>
          <strong>Wyniki:</strong>
          <xsl:for-each select="wyniki/pozycja">
            <xsl:sort select="@punkty" data-type="number" order="descending"/>
            <div class="small">
              Miejsce: <xsl:value-of select="@miejsce"/> — punkty: 
              <!-- format-number 2 (inne parametry) -->
              <xsl:value-of select="format-number(number(@punkty), '#,###')"/>
              — zawodnik: <xsl:value-of select="uczestnikRef/@id"/>
            </div>
          </xsl:for-each>
        </div>
      </xsl:if>

      <!-- galeria: obrazki + odnośniki -->
      <xsl:if test="galeria/zdjecie">
        <div class="gallery">
          <strong>Galeria zawodów:</strong>
          <xsl:for-each select="galeria/zdjecie">
            <img src="{@src}" alt="{@opis}"/>
          </xsl:for-each>
        </div>
      </xsl:if>

      <!-- linki: aktywne linki pobrane z XML (wymóg: aktywne linki) -->
      <xsl:if test="linki/link">
        <div class="links">
          <strong>Linki:</strong>
          <xsl:for-each select="linki/link">
            <a href="{normalize-space(.)}" target="_blank" title="{@typ}">
              <xsl:value-of select="concat(translate(substring(@typ,1,1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring(@typ,2))"/>
            </a>
          </xsl:for-each>
        </div>
      </xsl:if>

    </div>
  </xsl:template>

  <!-- Template dopasowany do atrybutu (wymóg: przynajmniej 1 szablon dopasowany do atrybutu) -->
  <xsl:template match="@rok">
    <span class="small">Rok zawodów: <xsl:value-of select="."/></span>
  </xsl:template>

  <!-- template dla zdjecie (elementowy) -->
  <xsl:template match="zdjecie">
    <!-- pusty: zdjecia są wstawiane bezpośrednio w miejscu użycia -->
  </xsl:template>

  <!-- fallback: wszystkie elementy nie obsługiwane wcześniej -->
  <xsl:template match="*">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- funkcje/ekstra użycia:
       - użyto concat(), normalize-space(), substring-before(), string-length(),
         count(), format-number(), upper-case() (funkcja XSLT 2.0 normally; if your processor
         doesn't support upper-case(), you can replace with translate(...))
  -->

</xsl:stylesheet>