Init tables :
```bash
 docker exec -it time_manager_web /bin/sh
```

```bash
mix phx.gen.schema User users username:string:unique email:string:unique
mix phx.gen.schema Clock clocks time:naive_datetime status:boolean user_id:references:users
mix phx.gen.schema WorkingTime working_times start:naive_datetime end:naive_datetime user_id:references:users
```
Then use :
```bash
make migrate
```

When pulled do these commands: 

local : 
```bash
cd time_manager
mix deps.get
```
then : 
```bash
docker builder prune
make build
make up
```