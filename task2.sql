select * from (
-- кредитные операции
with c_op as (select account_id,
                    operation_date,
                    agreement_num,
                    operation_id,
                    amount,
                    row_number() over (partition by operation_date, agreement_num order by operation_id) rn
              from jt$operations
              where operation_type = 'C'
                and account_id = 1
                and operation_date between to_date('01.01.2009') and to_date('01.01.2009')
),
-- дебетовые операции
    d_op as (select account_id,
                   operation_date,
                   agreement_num,
                   operation_id,
                   amount,
                   row_number() over (partition by operation_date, agreement_num order by operation_id) rn
            from jt$operations d_op
            where d_op.operation_type = 'D'
                and account_id = 1
                and operation_date between to_date('01.01.2009') and to_date('01.01.2009')
)
-- сводим дебет с кредитом
select nvl(d_op.account_id, c_op.account_id) account_id,
        nvl(d_op.operation_date, c_op.operation_date) operation_date,
        nvl(d_op.agreement_num, c_op.agreement_num) agreement_num,
        d_op.operation_id d_operation_id,
        d_op.amount d_amount,
        c_op.operation_id c_operation_id,
        c_op.amount c_amount
from d_op
full join c_op
    on d_op.account_id = c_op.account_id
        and d_op.operation_date = c_op.operation_date
        and ((d_op.agreement_num = c_op.agreement_num) or (d_op.agreement_num is null and c_op.agreement_num is null))
        and d_op.rn = c_op.rn
)
order by operation_date, agreement_num nulls first, d_operation_id, c_operation_id
