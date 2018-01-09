with fs
as
(
select i.object_id,
        p.rows AS RowCounts,
        CAST((SUM(a.total_pages) * 8. / 1024) AS DECIMAL(8,2)) AS TotalSpaceMB ,
        CAST((SUM(a.total_pages) * 8. / 1024)/1024 AS DECIMAL(8,2)) AS TotalSpaceGB        
from     sys.indexes i INNER JOIN 
        sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id INNER JOIN 
         sys.allocation_units a ON p.partition_id = a.container_id
WHERE 
    i.OBJECT_ID > 255 
    and p.rows > 0
GROUP BY 
    i.object_id,
    p.rows
)


SELECT 
    t.NAME AS TableName,
    fs.RowCounts,
    fs.TotalSpaceMB,
    fs.TotalSpaceGB,
    t.create_date,
    t.modify_date,
    ( select COUNT(1)
        from sys.columns c 
        where c.object_id = t.object_id ) TotalColumns    
FROM 
    sys.tables t INNER JOIN      
    fs  ON t.OBJECT_ID = fs.object_id
WHERE 
    t.NAME NOT LIKE 'dt%' 
    AND t.is_ms_shipped = 0
ORDER BY 
    fs.TotalSpaceGB desc