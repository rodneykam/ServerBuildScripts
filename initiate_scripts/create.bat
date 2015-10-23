call env.set
call GenerateConfig
call GenerateDicUpdateScript
call file.copy
call datasource.create
call hub.create
call hub.dic.load
call instance.create
