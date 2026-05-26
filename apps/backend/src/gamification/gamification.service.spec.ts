import { scoreQuiz, getPoliticalLevel } from "@swaraj/shared-utils";

describe("gamification utilities", () => {
  it("scores quiz accuracy as political IQ points", () => {
    expect(scoreQuiz(3, 4)).toBe(75);
    expect(scoreQuiz(0, 0)).toBe(0);
  });

  it("resolves political levels from thresholds", () => {
    expect(getPoliticalLevel(0)).toBe("Citizen");
    expect(getPoliticalLevel(300)).toBe("Volunteer");
    expect(getPoliticalLevel(750)).toBe("Leader");
    expect(getPoliticalLevel(1300)).toBe("Young Minister");
  });
});
