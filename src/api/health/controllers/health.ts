module.exports = {
  async check(ctx) {
    ctx.send({
      status: "ok",
      timestamp: new Date().toISOString(),
    });
  },
};