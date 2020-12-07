select min(cal_day) beg_date,
        max(cal_day) end_date,
        saldo
from (
select cal.cal_day, sum(out_saldo) saldo
from jt$calendar cal
inner join jt$saldo sal
    on cal.cal_day between sal.beg_date and sal.end_date
where cal.cal_day between to_date('10.12.2008') and to_date('20.01.2009')
    and sal.customer_id  = 1
group by cal.cal_day
)
group by saldo
order by min(cal_day)
