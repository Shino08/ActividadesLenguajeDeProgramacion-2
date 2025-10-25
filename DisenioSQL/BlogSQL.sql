CREATE TABLE administradores (
    idadmin INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    correo VARCHAR(100),
    contraseña VARCHAR(50),
    turno VARCHAR(20)
);

CREATE TABLE usuarios (
    idusuario INT PRIMARY KEY,
    nombre VARCHAR(50),
    apellido VARCHAR(50),
    email VARCHAR(100),
    telefono VARCHAR(20),
    contraseña VARCHAR(50),
    estadovip BOOLEAN,
    activo BOOLEAN
);

CREATE TABLE habitaciones (
    idhabitacion INT PRIMARY KEY,
    tipo VARCHAR(50),
    capacidad INT,
    precio DECIMAL(10,2),
    estado VARCHAR(20),
    creadapor_admin INT,
    actualizado_por_admin INT,
    FOREIGN KEY (creadapor_admin) REFERENCES administradores(idadmin),
    FOREIGN KEY (actualizado_por_admin) REFERENCES administradores(idadmin)
);

CREATE TABLE servicios (
    idservicio INT PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion TEXT,
    precio DECIMAL(10,2),
    creadopor_admin INT,
    FOREIGN KEY (creadopor_admin) REFERENCES administradores(idadmin)
);

CREATE TABLE notificaciones (
    idnotificacion INT PRIMARY KEY,
    idusuario INT,
    titulo VARCHAR(100),
    mensaje TEXT,
    fecha DATETIME,
    leido BOOLEAN,
    enviado_por_admin INT,
    FOREIGN KEY (idusuario) REFERENCES usuarios(idusuario),
    FOREIGN KEY (enviado_por_admin) REFERENCES administradores(idadmin)
);

CREATE TABLE reservas (
    idreserva INT PRIMARY KEY,
    idusuario INT,
    idhabitacion INT,
    fechainicio DATE,
    fechafin DATE,
    estado VARCHAR(20),
    modificado_por_admin INT,
    FOREIGN KEY (idusuario) REFERENCES usuarios(idusuario),
    FOREIGN KEY (idhabitacion) REFERENCES habitaciones(idhabitacion),
    FOREIGN KEY (modificado_por_admin) REFERENCES administradores(idadmin)
);

CREATE TABLE pagosservicio (
    idpago INT PRIMARY KEY,
    idreserva INT,
    monto DECIMAL(10,2),
    metodo VARCHAR(20),
    estado VARCHAR(20),
    comprobante VARCHAR(200),
    FOREIGN KEY (idreserva) REFERENCES reservas(idreserva)
);

CREATE TABLE pagosreserva (
    idpago INT PRIMARY KEY,
    idreserva INT,
    monto DECIMAL(10,2),
    metodo VARCHAR(20),
    estado VARCHAR(20),
    comprobante VARCHAR(200),
    FOREIGN KEY (idreserva) REFERENCES reservas(idreserva)
);

CREATE TABLE reservasservicios (
    idreserva INT,
    idservicio INT,
    fecha DATE,
    hora TIME,
    PRIMARY KEY (idreserva, idservicio),
    FOREIGN KEY (idreserva) REFERENCES reservas(idreserva),
    FOREIGN KEY (idservicio) REFERENCES servicios(idservicio)
);

CREATE TABLE historialadministradores (
    idhistorial INT PRIMARY KEY,
    idadmin INT,
    tablaafectada VARCHAR(50),
    idregistro INT,
    tipoaccion INT,
    descripcion TEXT,
    fechahora DATETIME,
    FOREIGN KEY (idadmin) REFERENCES administradores(idadmin)
);

CREATE TABLE detallespagosreserva (
    iddetallespago INT PRIMARY KEY,
    referencia_bancaria VARCHAR(100),
    notaspago VARCHAR(200),
    fecha VARCHAR(20),
    comprobante VARCHAR(200)
);

CREATE TABLE imagenes (
    idimagen INT PRIMARY KEY,
    url VARCHAR(200),
    imagenid INT,
    imagentipo VARCHAR(50)
);
