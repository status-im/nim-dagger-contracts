import web3

func toFixed*[N: static int](bytes: array[N, byte]): FixedBytes[N] =
  FixedBytes[N](bytes)

func toDynamic*(bytes: openArray[byte]): DynamicBytes[0, int.high] =
  DynamicBytes[0, int.high](@bytes)

func toArray*[N: static int](fixed: FixedBytes[N]): array[N, byte] =
  array[N, byte](fixed)

func toSeq*(dynamic: DynamicBytes): seq[byte] =
  seq[byte](dynamic)
