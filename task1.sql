-- задание 1
select deptno, emp_cnt, whole_sal, hire_jan_2009, round(sal_jan_2009/(whole_sal/100), 2) percent_jan_2009
from (  select deptno, 
                count(empno) emp_cnt, 
                sum(sal) whole_sal, 
                sum(case trunc(hiredate, 'MONTH') when to_date('01.01.2009') then 1 else 0 end) hire_jan_2009,
                sum(case trunc(hiredate, 'MONTH') when to_date('01.01.2009') then sal else 0 end) sal_jan_2009
        from jt$emp emp
        group by deptno
)
order by deptno;


-- задание 1а
select deptno, emp_cnt, whole_sal, hire_jan_2009, round(sal_jan_2009/(whole_sal/100), 2) percent_jan_2009
from (  select deptno, 
                count(empno) emp_cnt, 
                sum(sal) whole_sal, 
                sum(case trunc(hiredate, 'MONTH') when to_date('01.01.2009') then 1 else 0 end) hire_jan_2009,
                sum(case trunc(hiredate, 'MONTH') when to_date('01.01.2009') then sal else 0 end) sal_jan_2009
        from jt$emp emp
        where empno != 7698
        connect by prior empno = mgr
        start with empno = 7698
        group by deptno
)
order by deptno;
