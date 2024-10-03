import { Bom, Component } from "../cyclonedx/models";

export class CycloneDataLoader {
  public componentHash : Map<string, Component>;

  constructor(public bom: Bom | null, public disallowAnalysis: any) {
    this.componentHash = new Map<string, Component>();
    if (this.bom) {
      if (this.bom.components) {
        if (this.bom.components.length > 0) {
          this.bom.components.forEach(c => {
            this.componentHash.set(c["bom-ref"], c);
          });
        }
      }
    }
  }
}