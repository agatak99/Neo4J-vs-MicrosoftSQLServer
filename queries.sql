
use JamesBondMovies2

--  1. Do każdego aktora grającego Jamesa Bonda podaj liczbę filmów, w których wystąpił, posortowane malejąco
--WARIANT I
select P.Name as Actor, count(P.Name) as NumberOfBondMovies
from People as P, Film as F, AsBondIn
where match (P - (AsBondIn) -> F)
group by P.Name
order by NumberOfBondMovies desc

--WARIANT II
select P.Name as Actor, count(P.Name) as NumberOfBondMovies
from People as P
join AsBondIn ABI on P.$node_id=ABI.$from_id
join Film F on F.$node_id = ABI.$to_id
group by P.Name
order by NumberOfBondMovies desc


--2.Podaj aktora grającego Jamesa Bonda, który miał w sumie najwięcej dziewczyn
--WARIANT I
select top 1 with ties Bond.Name as Bond, count(distinct Girl.Name) as BondGirlsCount
from People Bond, AsBondIn, People Girl, IsBondGirlIn, Film
where match (Girl - (IsBondGirlIn) -> Film <- (AsBondIn) - Bond)
group by Bond.Name
order by BondGirlsCount desc

--WARIANT II
select top 1 with ties Bond.Name as Bond, count(distinct Girl.Name) as BondGirlsCount
from People Bond
join AsBondIn ABI on Bond.$node_id = ABI.$from_id
join Film F on ABI.$to_id = F.$node_id
join IsBondGirlIn IBGI on F.$node_id = IBGI.$to_id
join People Girl on Girl.$node_id = IBGI.$from_id
group by Bond.Name
order by BondGirlsCount desc

--3.Podaj Bonda mającego kontakt z największa liczbą reżyserów
--WARIANT I
select top 1 with ties Bond.Name as Actor, count(distinct Director.Name) as DirectorCount
from People Bond, AsBondIn, People Director, DirectorOf, Film
where match (Director - (DirectorOf) -> Film <- (AsBondIn) - Bond)
group by Bond.Name
order by DirectorCount desc

--WARIANT II
select top 1 with ties Bond.Name as Actor, count(distinct Director.Name) as DirectorCount
from People Bond
join AsBondIn ABI on Bond.$node_id = ABI.$from_id
join Film F on F.$node_id = ABI.$to_id
join DirectorOf DO on F.$node_id = DO.$to_id
join People Director on Director.$node_id = DO.$from_id
group by Bond.Name
order by DirectorCount desc

--4.Dla każdej “dziewczyny Bonda” podaj tytuł filmu, w którym wystąpiła oraz aktora grającego Bonda, któremu towarzyszyła.
--WARIANT I
select Girl.Name as BondGirl, Film.Name as Name,  Bond.Name as Bond
from People Girl, People Bond, Film, IsBondGirlIn, AsBondIn
where match (Girl - (IsBondGirlIn) -> Film <- (AsBondIn) - Bond)

--WARIANT II
select Girl.Name as BondGirl, F.Name as Name,  Bond.Name as Bond
from People Girl
join IsBondGirlIn IBGI on Girl.$node_id = IBGI.$from_id
join Film F on F.$node_id = IBGI.$to_id
join AsBondIn ABI on F.$node_id = ABI.$to_id
join People Bond on Bond.$node_id = ABI.$from_id

--5.Podaj “dziewczynę Bonda”, która pojawiła się w największej ilości produkcji.
--WARIANT I
select top 1 with ties Girl.Name as Actor, count(Film.Name) as NumberOfBondMovies
from People Girl, IsBondGirlIn, Film
where match (Girl - (IsBondGirlIn) -> Film)
group by Girl.Name
order by NumberOfBondMovies desc

--WARIANT II
select top 1 with ties Girl.Name as Actor, count(F.Name) as NumberOfBondMovies
from People Girl
join IsBondGirlIn IBGI on Girl.$node_id = IBGI.$from_id
join Film F on F.$node_id = IBGI.$to_id
group by Girl.Name
order by NumberOfBondMovies desc

--6. Dla każdej “dziewczyny Bonda” pokazać z iloma Bondami miała do czynienia, jeśli ta liczba jest większa od 1.
--WARIANT I
select Girl.Name as BondGirl, count(distinct Bond.Name) as DistinctBondCount
from People Girl, People Bond, IsBondGirlIn, AsBondIn, Film
where match (Girl - (IsBondGirlIn) -> Film <- (AsBondIn) - Bond)
group by Girl.Name
having count(distinct Bond.Name) > 1
order by DistinctBondCount desc

--WARIANT II
select Girl.Name as BondGirl, count(distinct Bond.Name) as DistinctBondCount
from People Girl
join IsBondGirlIn IBGI on Girl.$node_id = IBGI.$from_id
join Film F on F.$node_id = IBGI.$to_id
join AsBondIn ABI on F.$node_id = ABI.$to_id
join People Bond on Bond.$node_id = ABI.$from_id
group by Girl.Name
having count(distinct Bond.Name) > 1
order by DistinctBondCount desc

--7. Dla każdego Bonda podaj ile razy prezentował się w samochodzie danej marki.
--WARIANT I
select Bond.Name, Vehicle.Brand, count(Vehicle.Brand)
from People Bond, AsBondIn, Vehicle, HasVehicle, Film
where match (Bond - (AsBondIn) -> Film - (HasVehicle) -> Vehicle)
group by Bond.Name, Vehicle.Brand
order by Bond.Name

--WARIANT II
select Bond.Name, V.Brand, count(V.Brand)
from People Bond
join AsBondIn ABI on Bond.$node_id = ABI.$from_id
join Film F on F.$node_id = ABI.$to_id
join HasVehicle HV on F.$node_id = HV.$from_id
join Vehicle V on V.$node_id = HV.$to_id
group by Bond.Name, V.Brand
order by Bond.Name

--8. Podaj markę samochodów z największą liczbą różnych modeli ukazanych w filmach.
--WARIANT I
select top 1 with ties Vehicle.Brand as Brand, count(distinct Vehicle.Model) as DistinctModelCount
from Vehicle, HasVehicle, Film
where match (Film - (HasVehicle) -> Vehicle)
group by Brand
order by DistinctModelCount desc

--WARIANT II
select top 1 with ties V.Brand as Brand, count(distinct V.Model) as DistinctModelCount
from Vehicle V
join HasVehicle HV on V.$node_id = HV.$to_id
join Film F on F.$node_id = HV.$from_id
group by Brand
order by DistinctModelCount desc

--9. Podaj nazwę modelu samochodu, który ukazał się w największej ilości produkcji.
--WARIANT I
select top 1 with ties Vehicle.Brand as Brand, Vehicle.Model as Model, count(Film.Name) as MoviesCount
from Vehicle, HasVehicle, Film
where match (Film - (HasVehicle) -> Vehicle)
group by Brand, Model
order by MoviesCount desc

--WARIANT II
select top 1 with ties V.Brand as Brand, V.Model as Model, count(F.Name) as MoviesCount
from Vehicle V
join HasVehicle HV on V.$node_id = HV.$to_id
join Film F on F.$node_id = HV.$from_id
group by Brand, Model
order by MoviesCount desc

--10. Pokaż reżyserów realizujących kilka filmów (wraz z ich liczbą)
--WARIANT I
select Director.Name as Director, count(Film.Name) as MoviesCount
from People Director, DirectorOf, Film
where match (Director - (DirectorOf) -> Film)
group by Director.Name
having count(Film.Name)>1
order by MoviesCount desc

--WARIANT II
select Director.Name as Director, count(F.Name) as MoviesCount
from People Director
join DirectorOf DO on Director.$node_id = DO.$from_id
join Film F on F.$node_id = DO.$to_id
group by Director.Name
having count(F.Name)>1
order by MoviesCount desc

--11 Dla filmu o największym box-office pokaż jego tytuł, rok premiery, reżysera, Bonda
--WARIANT I
select top 1 Director.Name as Director, Bond.Name as Bond, Film.Name as Title, Film.Year as ProductionYear
from People Director, People Bond, AsBondIn, DirectorOf, Film
where match (Director - (DirectorOf) -> Film <- (AsBondIn) - Bond)
order by Convert(int, Film.Box) desc

--WARIANT II
select top 1 Director.Name as Director, Bond.Name as Bond, F.Name as Title, F.Year as ProductionYear
from People Director
join DirectorOf DO on Director.$node_id = DO.$from_id
join Film F on F.$node_id = DO.$to_id
join AsBondIn ABI on ABI.$to_id = F.$node_id
join People Bond on Bond.$node_id = ABI.$from_id
order by Convert(int, F.Box) desc

--12.Przy realizacji filmu, przez którego reżysera pojawiło się najwięcej aut.
--WARIANT I
select top 1 with ties Director.Name as Director, Film.Name as Title, count(Vehicle.Model) as CarModelCount
from People Director, DirectorOf, Film, Vehicle, HasVehicle
where match (Director - (DirectorOf) -> Film - (HasVehicle) -> Vehicle)
group by Director.Name, Film.Name
order by CarModelCount desc

--WARIANT II
select top 1 with ties Director.Name as Director, F.Name as Title, count(V.Model) as CarModelCount
from People Director
join DirectorOf DO on Director.$node_id = DO.$from_id
join Film F on F.$node_id = DO.$to_id
join HasVehicle HV on F.$node_id = HV.$from_id
join Vehicle V on V.$node_id = HV.$to_id
group by Director.Name, F.Name
order by CarModelCount desc

-- 13.Ile pojawiło się samochodów w filmie z największym box-office
--WARIANT I
select top 1 Film.Name as Title, Film.Box as BoxOffice, count(Vehicle.Model) as CarModelCount
from Film, Vehicle, HasVehicle
where match (Film - (HasVehicle) -> Vehicle)
group by Film.Name, Film.Box
order by Convert(int, Film.Box) desc

--WARIANT II
select top 1 F.Name as Title, F.Box as BoxOffice, count(V.Model) as CarModelCount
from Film F
join HasVehicle HV on F.$node_id = HV.$from_id
join Vehicle V on V.$node_id = HV.$to_id
group by F.Name, F.Box
order by Convert(int, F.Box) desc

--14. W czasie pracy, którego reżysera w sumie pojawiło się najwięcej aut
--WARIANT I
select top 1 with ties Director.Name as Director, count(Vehicle.Model) as CarModelCount
from People Director, DirectorOf, Film, Vehicle, HasVehicle
where match (Director - (DirectorOf) -> Film - (HasVehicle) -> Vehicle)
group by Director.Name
order by CarModelCount desc

--WARIANT II
select top 1 with ties Director.Name as Director, count(V.Model) as CarModelCount
from People Director
join DirectorOf DO on Director.$node_id = DO.$from_id
join Film F on F.$node_id = DO.$to_id
join HasVehicle HV on F.$node_id = HV.$from_id
join Vehicle V on V.$node_id = HV.$to_id
group by Director.Name
order by CarModelCount desc

--15 Podaj Bonda mającego kontakt tylko z 1 reżyserem
--WARIANT I
select Bond.Name as Bond, Director.Name as Director
from People Bond, People Director, AsBondIn, DirectorOf, Film
where match (Director - (DirectorOf) -> Film <- (AsBondIn) - Bond) and Bond.Name in
(
    select Bond.Name as Bond
    from People Bond, People Director, AsBondIn, DirectorOf, Film
    where match (Director - (DirectorOf) -> Film <- (AsBondIn) - Bond)
    group by Bond.Name
    having count(Director.Name)=1
)

--WARIANT II
select Bond.Name as Bond, Director.Name as Director
from People Director
join DirectorOf DO on Director.$node_id = DO.$from_id
join Film F on F.$node_id = DO.$to_id
join AsBondIn ABI on ABI.$to_id = F.$node_id
join People Bond on Bond.$node_id = ABI.$from_id
where Bond.Name in
(
    select Bond.Name as Bond
    from People Director
    join DirectorOf DO on Director.$node_id = DO.$from_id
    join Film F on F.$node_id = DO.$to_id
    join AsBondIn ABI on ABI.$to_id = F.$node_id
    join People Bond on Bond.$node_id = ABI.$from_id
    group by Bond.Name
    having count (Director.Name)=1
)

--16. Podaj łączny box-office całej serii filmów o Jamesie Bondzie
select SUM(CAST(Box as  BIGINT))
from Film

--17 Podaj średni box - office
select AVG(CAST(Box as  BIGINT))
from Film

--18 Podaj markę i model wszystkich samochodów, w których nazwie wystąpiło słowo sedan lub coupe
select Brand, Model
from Vehicle
where  Model like '%sedan%' OR Model like '%coupe%'

--19. Podaj tytuły wszystkich filmów zaczynających się od słowa “The”
select Name as Title
from Film
where Name like 'The%'

--20 Wypisz wszystkie osoby, które w nazwie posiadają “ros”
select Name
from People
where Name like '%ros%'