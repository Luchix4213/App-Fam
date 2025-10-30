-- Creating the table for associations
CREATE TABLE asociaciones (
    id SERIAL PRIMARY KEY,
    alias VARCHAR(50),
    nombre VARCHAR(200),
    presidente VARCHAR(100),
    telefono_personal VARCHAR(50),
    telefono_publico VARCHAR(50),
    municipio VARCHAR(100),
    telefono_fax VARCHAR(50),
    correo_personal VARCHAR(100),
    correo_publico VARCHAR(100),
    tipo VARCHAR(50),
    direccion VARCHAR(200),
    estado VARCHAR(20),
    id_departamento INTEGER
);

-- Inserting data into the asociaciones table
INSERT INTO asociaciones (alias, nombre, presidente, telefono_personal, telefono_publico, municipio, telefono_fax, correo_personal, correo_publico, tipo, direccion, estado, id_departamento) VALUES
('AGAMDEPAZ', 'ASOCIACION DE GOBIERNOS AUTONOMOS MUNICIPALES DEL DEPARTAMENTO DE LA PAZ', 'Neusa Coca Gonzales', '68177882', '77777778', 'TEOPONTE', '2-2004088 - 2-2004088', 'agamdepazbolivia@gmail.com', 'exampleagamdepaz@gmail.com', 'AMDES', 'Calle Jorge Saenz N°1174 zona Miraflores (a dos cuadras de la plaza Uyuni)', 'activo', 1),
('AMDECRUZ', 'ASOCIACIÓN DE MUNICIPIOS DE SANTA CRUZ', 'Juan Carlos Valles Mamani', '73396723', '11111114', 'YAPACANI', '3-3363297 - 3-3363297', 'comunicación@amdecruz.com', 'exampleagamdecruz@gmail.com', 'AMDES', 'Av. Pirai, Calle Ignacio Castedo, tres cuadras antes del cuarto Anillo', 'activo', 2),
('AMDECO', 'ASOCIACIÓN DE MUNICIPIOS DE COCHABAMBA', 'Daniel Fernando Vallejo Vargas', '74356017', '11111112', 'TARATA', '4- 4457404 - 4-4457406', 'amdeco@amdeco.org.bo', 'exampleagamdecruz@gmail.com', 'AMDES', 'Calle J. de los Rios entre E. Pérez y Av. Circunvalación N°317 acera oeste', 'activo', 3),
('AMDEPO', 'ASOCIACIÓN DE MUNICIPALIDADES DE POTOSÍ', 'Juan Navia LLanos', '79456620', '11111113', 'VILLAZON', '2-6230192 - 2-6310314', 'potosiamdepo@gmail.com', 'exampleagamdepotosi@gmail.com', 'AMDES', 'C. Cardenas N° 54 entre calles boqueron y 07 de agosto, Zona Villa Urkupiña', 'activo', 4),
('AMDEOR', 'ASOCIACIÓN DE MUNICIPIOS DEL DEPARTAMENTO DE ORURO', 'Grover Mariano Choque Calle', '74075716', '11111114', 'CURAHUARA DE CARANGAS', '2- 5259482 - 2-5259482', 'amdeormunicipios@gmail.com', 'exampleagamdeoruro@gmail.com', 'AMDES', 'Calle Junín, esq. Soria Galvarro y 6 de octubre N°563', 'activo', 5),
('AGAMDECH', 'ASOCIACIÓN DE GOBIERNOS AUTÓNOMOS MUNICIPALES DE CHUQUISACA', 'Dorfio Mansilla Avendaño', '72875544', '11111115', 'CAMARGO', '4- 6431744 - 71164518', 'agamdech29@gmail.com', 'exampleagamdechuquisaca@gmail.com', 'AMDES', 'Avenida 2001 /Nº519', 'activo', 6),
('AMDEBENI', 'ASOCIACIÓN DE GOBIERNOS AUTÓNOMOS MUNICIPALES DE BENI', 'Yascara Moreno Flores', '67359195', '11111116', 'LORETO', '3-4634271 - 4634271', 'amdebeni@hotmail.com', 'exampleagamdebeni@gmail.com', 'AMDES', 'Calle Félix Satori N°79 entre Nicolás Suarez y 18 de Noviembre', 'activo', 7),
('AMDEPANDO', 'ASOCIACIÓN DE MUNICIPALIDADES DE PANDO', 'Gary Verner Von Boeck', '76105015', '11111117', 'BELLA FLOR', '3-8421554 - 3-8421554', 'asociacionamdepando@gmail.com', 'exampleagamdepando@gmail.com', 'AMDES', 'Barrio 11 de octubre, Av. los Tajibos N°122 diagonal funeraria Gómez', 'activo', 8),
('AMDEPANDO', 'ASOCIACIÓN DE MUNICIPIOS DEL DEPARTAMENTO DE TARIJA', 'Asunción Ramos', '68703115', '11111118', 'SAN LORENZO', '4- 6647464 - 4- 6647464', 'Amtja2020@gmail.com', 'exampleagamdetarija@gmail.com', 'AMDES', 'Barrio Juan XXIII, Av. Julio Delio Echazu-280 entre Av. Jaime Paz y Belgrano', 'activo', 9),
('ACOBOL', 'ASOCIACIÓN DE CONCEJALAS Y ALCALDESAS DE BOLIVIA', 'Sara Armella Rueda', '73499578', '11111119', 'EL PUENTE', '2 - 780777 - 2 - 780778', 'acobol@acobol.org.bo', 'exampleacobol@gmail.com', 'ACOBOL', 'Av. 14 de septiembre Nº 6154 entre calles15 y 16 de Obrajes', 'activo', 10),
('AMB', 'ASOCIACIÓN DE MUNICIPALIDADES DE BOLIVIA', 'Ana Lucia Reis Melena', '72921506', '11111110', 'COBIJA', '2 129801 - 4 4305067', 'ambolivia2022@gmail.com', 'exampleacobol@gmail.com', 'AMB', 'Av. 14 de septiembre Nº 6154 entre calles 15 y 16 de Obrajes', 'activo', 11);