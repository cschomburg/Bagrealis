local addon, ns = ...

ns.LDD = LibStub("LibDragDrop-1.0")

function ns.dummy() end

function ns.minmax(value, min, max)
	return (value > max and max) or (value < min and min) or value
end