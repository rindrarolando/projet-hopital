Create role Hopital with Password 'Hopital';
Create database Hopital;
Alter database Hopital owner to Hopital;
/* SEQUENCE */
Create sequence chambre_sec;

/* TABLES */
Create table maladie(
    id serial NOT NULL PRIMARY KEY,
    description TEXT,
    echelle  int
);

INSERT INTO maladie(description,echelle) values('Diabete',3);
INSERT INTO maladie(description,echelle) values('Insuffisance reinale',2);
INSERT INTO maladie(description,echelle) values('AVC',1);
INSERT INTO maladie(description,echelle) values('Cancer',2);



Create table patient(
    id SERIAL NOT NULL primary key,
    nom varchar(30),
    dtn date,
    idmaladie int NOT NULL references maladie(id),
    statut varchar(15) check(statut in('En traitement','Gueri')),
    date_entree date,
    date_sortie date default null
);
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree) values('Eloic','2002-10-6',1,'En traitement','2022-9-3');
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree) values('Irina','2002-2-12',2,'En traitement','2022-10-22');
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree,date_sortie) values('Dina','2003-1-15',3,'Gueri','2022-10-12','2022-10-25');
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree,date_sortie) values('Andy','2002-2-7',4,'Gueri','2022-8-10','2022-8-24');
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree,date_sortie) values('Tahiry','2005-2-7',4,'Gueri','2022-8-10','2022-11-16');
INSERT INTO patient(nom,dtn,idmaladie,statut,date_entree) values('Cedric','2002-10-7',3,'En traitement','2022-8-10');

Create table chambre(
    id varchar(12) NOT NULL PRIMARY KEY default (concat('chambre',nextval('chambre_sec'))),
    capacite int CHECK (capacite>=1 AND capacite<=6),
    prixparjour float
);

INSERT INTO chambre(id,capacite,prixparjour) values('chambre'||nextval('chambre_sec'),2,150000);
INSERT INTO chambre(id,capacite,prixparjour) values('chambre'||nextval('chambre_sec'),4,250000);
INSERT INTO chambre(id,capacite,prixparjour) values('chambre'||nextval('chambre_sec'),2,270000);
INSERT INTO chambre(id,capacite,prixparjour) values('chambre'||nextval('chambre_sec'),2,145000);




Create table medecin(
    id serial NOT NULL primary key,
    nom varchar(30),
    dtn date,
    statut varchar(15) check(statut in('Infirmier','Generaliste','Specialiste','Professionel')),
    salaire_base float NOT NULL,
    prime float default null
);
Insert into medecin(nom,dtn,statut,salaire_base) values('Ramarokoto Bryan','2002-12-20','Specialiste',5000000);
Insert into medecin(nom,dtn,statut,salaire_base) values('Roger','2003-10-31','Generaliste',4000000);




Create table hebergement(
    id Serial Not Null Primary Key,
    idchambre varchar(12) NOT NULL references chambre(id),
    idpatient int NOT NULL references patient(id)
);
INSERT INTO hebergement(idchambre,idpatient) values('chambre1',1);
INSERT INTO hebergement(idchambre,idpatient) values('chambre2',2);
INSERT INTO hebergement(idchambre,idpatient) values('chambre3',3);
INSERT INTO hebergement(idchambre,idpatient) values('chambre4',4);
INSERT INTO hebergement(idchambre,idpatient) values('chambre1',5);
INSERT INTO hebergement(idchambre,idpatient) values('chambre2',6);



Create table devis(
    id SERIAL Not  Null Primary Key,
    idpatient int NOT NULL references patient(id),
    idchambre varchar(12) NOT NULL references chambre(id),
    sejour int,
    montant float,
    date_paiement date
);

INSERT INTO devis(idpatient,idchambre,sejour,montant,date_paiement) values(3,'chambre3',13,total_devis(3,13),'2022-10-25');
INSERT INTO devis(idpatient,idchambre,sejour,montant,date_paiement) values(4,'chambre4',14,total_devis(4,14),'2022-8-24');
INSERT INTO devis(idpatient,idchambre,sejour,montant,date_paiement) values(5,'chambre1',14,total_devis(4,91),'2022-11-16');



Create table traitement (
    id SERIAL NOT NULL PRIMARY KEY,
    idpatient int NOT NULL references patient(id),
    idmedecin int NOT NULL references medecin(id),
    date_traitement date
);

INSERT INTO traitement (idpatient,idmedecin,date_traitement) VALUES(1,1,'2022-9-6');
INSERT INTO traitement (idpatient,idmedecin,date_traitement) VALUES(2,2,'2022-10-25');
INSERT INTO traitement (idpatient,idmedecin,date_traitement) VALUES(2,1,'2022-10-6');


/* REQUETE */
/* Patient */
/* Liste patient */
Select * from patient;
/* Description du patient */
select m.description,p.nom from maladie m join patient p on p.idmaladie=m.id where p.idpatient=/* Nombre */;

/* Docteur */
/* Liste docteur */
Select * from medecin;

/* Chambre */
/* Liste des chambres */
Select * from chambre;

/* nombre des chambres */
Select count(*) from chambre;

/* Liste des patients dans chaque chambre */
select h.idchambre,p.nom from hebergement h join chambre c on h.idchambre=c.id join patient p on h.idpatient=p.id where c.id=/* idchambre */;

/*Liste des patients des patients que chaque medecin à traité*/
 select p.nom,m.nom,t.date_traitement from traitement t join medecin m on m.id=t.idmedecin join patient p on p.id=t.idpatient where m.id=/* idmedecin */;
/* FONCTION */
/* Calcul du devis */
Create or replace function total_devis(idp int,sejour int)
returns float
language plpgsql
as 
$$
declare 
prixchambre integer;
begin 
select c.prixparjour into prixchambre from hebergement h join chambre c on h.idchambre=c.id join patient p on h.idpatient=p.id where p.id=idp;
prixchambre=prixchambre*sejour;
return prixchambre;
end;
$$;


/* Fonction salaire des medecins */
Create or replace function salaire_medecin(statut varchar,id_medecin int)
returns float
language plpgsql
as 
$$
declare
salaire_base integer;
nombre_patient integer;
begin
IF statut ='Infirmier' THEN
salaire_base=100000;

elsif statut='Generaliste' THEN
salaire_base=275000;

elsif statut='Specialiste' THEN
salaire_base=400000;

elsif statut='Professionel'THEN
salaire_base=575000;
END IF;

select count(idpatient) into nombre_patient from traitement where idmedecin=id_medecin;
IF nombre_patient =0 or nombre_patient =1 THEN
    salaire_base=salaire_base;
ELSE
salaire_base=salaire_base*nombre_patient;
END IF;
return salaire_base;
end;
$$;


/* Trigger avance */
/* Fonction du trigger */
Create or replace function paiement_avance()
returns TRIGGER
 LANGUAGE PLPGSQL
  AS
$$
declare
date_e date;
BEGIN
select date_entree into date_e from Patient where id=NEW.idpatient;
    INSERT INTO devis(idpatient,idchambre,sejour,montant,date_paiement) VALUES(NEW.idpatient,NEW.idchambre,1,200000,date_e);
return NEW;
END;
$$;

/* Le trigger en question */
CREATE or replace TRIGGER paye_avance
  AFTER INSERT
  ON Hebergement  
  FOR EACH ROW
  EXECUTE PROCEDURE paiement_avance();