-- Creating the table for departments
CREATE TABLE departamentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100)
);

-- Inserting data into the departamentos table
INSERT INTO departamentos (nombre) VALUES
('La Paz'),
('Santa Cruz'),
('Cochabamba'),
('Potosi'),
('Oruro'),
('Chuquisaca'),
('Beni'),
('Pando'),
('Tarija'),
('Acobol');