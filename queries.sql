select
  b.booking_id,u.name as customer_name,v.name as vehicle_name,b.start_date,b.end_date,b.status 
  from bookings as b 
  inner join users as u on b.user_id=u.user_id
  inner join vehicles as v on b.vehicle_id=v.vehicle_id;

select 
  vehicle_id,name,type,model,registration_number,rental_price,status
  from vehicles
  where not exists( select * from bookings where vehicle_id=vehicles.vehicle_id);


select  * from vehicles where type='car' and status='available';


select
    v.name as vehicle_name,
    count(v.vehicle_id) as total_bookings
from
    bookings as b
left join
    vehicles as v on b.vehicle_id = v.vehicle_id
group by
    v.name having count(v.vehicle_id) > 2;