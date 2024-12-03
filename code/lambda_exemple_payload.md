Start using tag "automation_start" set "8am"
{
  "tag_value": "8am",
  "tag": "automation_start",
  "action": "start"
}

Start using tag "automation_ecs_stop_start"(default) set "8-20"
{
  "tag_value": "8-20",
  "action": "start"
}

Stop using tag "automation_start" set "8am"
{
  "tag_value": "8am",
  "tag": "automation_start",
  "action": "start"
}

Stop using tag "automation_ecs_stop_start"(default) set "8-20"
{
  "tag_value": "8-20",
  "action": "Stop"
}

Definet desired_count = 10 using tag "market" set "sales"
{
  "tag_value": "sales",
  "tag": "market",
  "action": "upgrade"
  "desired_count" = 10

}