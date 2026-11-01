// Run while connected to any reachable member of rsTransMove.

const status = rs.status();
print('Replica set: ' + status.set);
printjson(status.members.map(member => ({
  host: member.name,
  state: member.stateStr,
  health: member.health,
  message: member.lastHeartbeatMessage
})));

const hello = db.hello();
printjson({
  connectedMember: hello.me,
  primary: hello.primary,
  isWritablePrimary: hello.isWritablePrimary,
  isSecondary: hello.secondary
});
