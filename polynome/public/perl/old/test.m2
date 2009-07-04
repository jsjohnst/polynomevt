dis := method()
dis(ZZ) := n -> (
    m:={};
    if n>0 then m=append(m,n) else m=append(m,-n)
)

bis = method()
bis(ZZ) := n -> (dis(n))

