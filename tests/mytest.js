describe("A suite", function() {
  print
  it("contains spec with an expectation", function() {
    expect(true).toBe(true);
  });

  it("fails when overridden", function () {
    if (false) {
      fail("asked to fail");
    }
  });
});
