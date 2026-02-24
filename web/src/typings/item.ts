export type ItemData = {
  name: string;
  label: string;
  stack: boolean | number;
  usable: boolean;
  close: boolean;
  count: number;
  description?: string;
  buttons?: string[];
  ammoName?: string;
  image?: string;
};
