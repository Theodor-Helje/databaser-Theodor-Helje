USE bokhandel;
GO


/*
   Testdata och kod genererat av ChatGPT.
   Prompt: Givet följande tabeller, skriv instert-satser för att generera data enligt uppgiften.
   Bifogat: Bild på kraven för testdatan och hur jag har strukturerat mina tabeller.
*/


/* =========================================================
   TESTDATA FÖR BOKHANDELSSYSTEM
   - Minst 3 butiker
   - 4 författare
   - 10 böcker
   - LagerSaldo för demonstration
   ========================================================= */


/* =========================
   ADRESSER
   ========================= */
INSERT INTO Adresser (Postnummer, LAND, Stad)
VALUES
('11122', 'Sverige', 'Stockholm'),
('41110', 'Sverige', 'Göteborg'),
('21420', 'Sverige', 'Malmö'),
('75240', 'Sverige', 'Uppsala');


/* =========================
   FÖRLAG
   ========================= */
INSERT INTO Förlag (Namn)
VALUES
('Nordic Books'),
('TechPress'),
('Akademiska Förlaget'),
('Romanhuset');


/* =========================
   BUTIKER (minst 3)
   ========================= */
INSERT INTO Butiker (Butiksnamn, Adress, Postnummer)
VALUES
('Bokhörnan Stockholm', 'Drottninggatan 12', '11122'),
('Läs & Lär Göteborg', 'Avenyn 5', '41110'),
('Sydsveriges Böcker', 'Storgatan 18', '21420');


/* =========================
   FÖRFATTARE (minst 4)
   ========================= */
INSERT INTO Författare (Förnamn, Efternamn, Födelsedatum)
VALUES
('Astrid', 'Lindgren', '1907-11-14'),
('Jan', 'Guillou', '1944-01-17'),
('Camilla', 'Läckberg', '1974-08-30'),
('Fredrik', 'Backman', '1981-06-02');


/* =========================
   BÖCKER (minst 10)
   ========================= */
INSERT INTO Böcker
(ISBN, Titel, Språk, Pris, Utgivningsdatum, FörlagID)
VALUES
('9780000000001', 'Bröderna Lejonhjärta', 'Svenska', 129.00, '1973-09-01', 1),
('9780000000002', 'Mio min Mio', 'Svenska', 119.00, '1954-01-01', 1),
('9780000000003', 'Ondskan', 'Svenska', 149.00, '1981-01-01', 2),
('9780000000004', 'Brobyggarna', 'Svenska', 179.00, '2011-05-01', 2),
('9780000000005', 'Isprinsessan', 'Svenska', 159.00, '2003-04-15', 4),
('9780000000006', 'Predikanten', 'Svenska', 165.00, '2004-06-10', 4),
('9780000000007', 'En man som heter Ove', 'Svenska', 189.00, '2012-08-27', 4),
('9780000000008', 'Björnstad', 'Svenska', 199.00, '2016-09-15', 4),
('9780000000009', 'SQL för Nybörjare', 'Svenska', 249.00, '2020-01-10', 3),
('9780000000010', 'Databaser Avancerad', 'Svenska', 299.00, '2021-03-20', 3);


/* =========================
   KOPPLA FÖRFATTARE TILL BÖCKER
   ========================= */
INSERT INTO FörfattareBokJunktion (FörfattareID, ISBN)
VALUES
(1, '9780000000001'),
(1, '9780000000002'),

(2, '9780000000003'),
(2, '9780000000004'),

(3, '9780000000005'),
(3, '9780000000006'),

(4, '9780000000007'),
(4, '9780000000008'),

(2, '9780000000009'),
(2, '9780000000010');


/* =========================
   LAGERSALDO
   Demonstrationsdata för alla butiker
   ========================= */
INSERT INTO LagerSaldo (ButikId, ISBN, Antal)
VALUES

/* Stockholm */
(1, '9780000000001', 12),
(1, '9780000000002', 8),
(1, '9780000000003', 5),
(1, '9780000000007', 10),
(1, '9780000000009', 7),

/* Göteborg */
(2, '9780000000004', 6),
(2, '9780000000005', 9),
(2, '9780000000006', 4),
(2, '9780000000008', 11),
(2, '9780000000010', 3),

/* Malmö */
(3, '9780000000001', 2),
(3, '9780000000003', 7),
(3, '9780000000005', 5),
(3, '9780000000007', 9),
(3, '9780000000010', 8);


/* =========================
   ANSTÄLLDA
   ========================= */
INSERT INTO Anställda
(Förnamn, Efternamn, Arbetstitel, ButikId)
VALUES
('Anna', 'Svensson', 'Butikschef', 1),
('Erik', 'Johansson', 'Säljare', 1),
('Maria', 'Karlsson', 'Butikschef', 2),
('Oskar', 'Nilsson', 'Säljare', 3);


/* =========================
   KUNDER
   ========================= */
INSERT INTO Kunder (UserName, EmailAdress)
VALUES
('bokalskare91', 'bokalskare91@mail.se'),
('sqlstudent', 'sqlstudent@mail.se'),
('romanfantast', 'romanfantast@mail.se');


/* =========================
   ORDRAR
   ========================= */
INSERT INTO Ordrar
(KundID, AnställdID, ButikID, Adress, Beställt, Skickat)
VALUES
(1, 1, 1, 'Testgatan 1, Stockholm', '2024-05-01', '2024-05-03'),
(2, 3, 2, 'Exempelvägen 5, Göteborg', '2024-05-02', '2024-05-04'),
(3, 4, 3, 'Demogatan 9, Malmö', '2024-05-05', NULL);


/* =========================
   ORDERDETALJER
   ========================= */
INSERT INTO OrderDetaljer
(OrderID, BokID, Antal, Kostnad)
VALUES
(1, '9780000000001', 1, 129.00),
(1, '9780000000009', 1, 249.00),

(2, '9780000000005', 2, 318.00),

(3, '9780000000007', 1, 189.00),
(3, '9780000000010', 1, 299.00);